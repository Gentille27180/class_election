import 'package:flutter/material.dart';

void main() {
  runApp(const ElectionApp());
}

// ---------------------------------------------------------------
// App
// ---------------------------------------------------------------
class ElectionApp extends StatelessWidget {
  const ElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Vote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const VoteScreen(),
    );
  }
}

// ---------------------------------------------------------------
// Model: one candidate and his or her votes
// ---------------------------------------------------------------
class Candidate {
  Candidate(this.name);

  final String name;
  int votes = 0; // not final, because it changes
}

// ---------------------------------------------------------------
// Rules (all outside build)
// ---------------------------------------------------------------

// "  keza   uwase " -> "Keza Uwase"
String cleanName(String text) {
  final words = text.trim().split(' ');
  final cleaned = <String>[];
  for (final word in words) {
    if (word.isEmpty) continue; // skip extra spaces
    cleaned.add(word[0].toUpperCase() + word.substring(1).toLowerCase());
  }
  return cleaned.join(' ');
}

// Add up all the votes
int totalVotes(List<Candidate> candidates) {
  int total = 0;
  for (final c in candidates) {
    total = total + c.votes;
  }
  return total;
}

// Copy the list and sort it: highest votes first
List<Candidate> rankCandidates(List<Candidate> candidates) {
  final ranked = List<Candidate>.from(candidates);
  ranked.sort((a, b) => b.votes.compareTo(a.votes));
  return ranked;
}

// Winner, tie, or no votes
String bannerText(List<Candidate> candidates) {
  if (totalVotes(candidates) == 0) {
    return 'No votes yet';
  }
  final ranked = rankCandidates(candidates);
  final topVotes = ranked.first.votes;

  // everybody who has the top score
  final leaders = ranked.where((c) => c.votes == topVotes).toList();

  if (leaders.length == 1) {
    return 'Winner: ${leaders.first.name}';
  }

  final names = leaders.map((c) => c.name).toList();
  final last = names.removeLast();
  final start = names.join(', ');
  return 'Tie between $start and $last ($topVotes votes each)';
}

// ---------------------------------------------------------------
// Screen 1: Vote
// ---------------------------------------------------------------
class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final candidates = [
    Candidate('Keza'),
    Candidate('Mutoni'),
    Candidate('Aline'),
  ];
  final voters = <String>[]; // cleaned names of people who already voted
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void vote(Candidate candidate) {
    final voter = cleanName(nameController.text);

    if (voter.isEmpty) {
      showMessage('Please type your name first');
      return;
    }
    if (voters.contains(voter)) {
      showMessage('$voter has already voted');
      return;
    }

    setState(() {
      candidate.votes++;
      voters.add(voter);
    });
    nameController.clear();
    showMessage('$voter voted for ${candidate.name}');
  }

  void resetVotes() {
    setState(() {
      for (final c in candidates) {
        c.votes = 0;
      }
      voters.clear();
    });
  }

  void askReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset all votes?'),
          content: const Text('This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                resetVotes();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void openResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(candidates: candidates),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void openCandidates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatesScreen(candidates: candidates),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Vote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Results',
            onPressed: openResults,
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Candidates',
            onPressed: openCandidates,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: askReset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Votes so far: ${totalVotes(candidates)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: candidates.isEmpty
                  ? const Center(child: Text('No candidates yet'))
                  : ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(candidate.name),
                            trailing: FilledButton(
                              onPressed: () => vote(candidate),
                              child: const Text('Vote'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// Screen 2: Results
// ---------------------------------------------------------------
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.candidates});

  final List<Candidate> candidates;

  @override
  Widget build(BuildContext context) {
    final ranked = rankCandidates(candidates);
    final total = totalVotes(candidates);

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                bannerText(candidates),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ranked.isEmpty
                  ? const Center(child: Text('No candidates yet'))
                  : ListView.builder(
                      itemCount: ranked.length,
                      itemBuilder: (context, index) {
                        final c = ranked[index];
                        // never divide by 0 (that would give NaN)
                        final share = total == 0 ? 0.0 : c.votes / total;
                        final percent = (share * 100).toStringAsFixed(1);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${c.name}  -  ${c.votes} votes  ($percent%)',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: share,
                                minHeight: 12,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// Screen 3: Candidates (add and remove)
// ---------------------------------------------------------------
class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key, required this.candidates});

  final List<Candidate> candidates;

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void addCandidate() {
    final name = cleanName(nameController.text);

    if (name.isEmpty) {
      showMessage('The name cannot be empty');
      return;
    }
    // compare in lower case, so "keza" and "Keza" are the same
    final exists = widget.candidates.any(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      showMessage('$name is already a candidate');
      return;
    }

    setState(() {
      widget.candidates.add(Candidate(name));
    });
    nameController.clear();
  }

  void removeCandidate(Candidate candidate) {
    if (candidate.votes > 0) {
      showMessage('${candidate.name} has votes and cannot be removed');
      return;
    }
    setState(() {
      widget.candidates.remove(candidate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidates')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'New candidate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: addCandidate,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.candidates.isEmpty
                  ? const Center(child: Text('No candidates yet'))
                  : ListView.builder(
                      itemCount: widget.candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = widget.candidates[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(candidate.name),
                          subtitle: Text('${candidate.votes} votes'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeCandidate(candidate),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
