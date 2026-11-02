import 'package:flutter_test/flutter_test.dart';
import 'package:class_election/main.dart';

void main() {
  test('cleanName fixes spaces and capitals', () {
    expect(cleanName('  keza   uwase '), 'Keza Uwase');
    expect(cleanName(' aLINE '), 'Aline');
  });

  test('banner says tie when top score is shared', () {
    final a = Candidate('Keza')..votes = 4;
    final b = Candidate('Mutoni')..votes = 4;
    final c = Candidate('Aline')..votes = 1;
    expect(bannerText([a, b, c]), 'Tie between Keza and Mutoni (4 votes each)');
  });

  test('banner says no votes yet at the start', () {
    expect(bannerText([Candidate('Keza')]), 'No votes yet');
  });
}
