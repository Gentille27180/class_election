# Class Vote

**Project chosen:** Class Election (Mobile Programming, Week 2 Mini Project)

A small Flutter app where the class elects its representative. Every vote counts once, the results are ranked, and a tie is never shown as a fake winner.

## Features
- 3 sample candidates to start
- Names are cleaned (spaces removed, Title Case): `  keza  uwase ` becomes `Keza Uwase`
- Each voter can vote only once (`aline` and ` ALINE ` are the same voter)
- Results screen: votes, percentage with one decimal, a bar, and a banner (Winner / Tie / No votes yet)
- Results ranked from highest to lowest votes
- Add a candidate (not empty, not a duplicate)
- Remove a candidate (only if they have no votes)
- Reset all votes, after an "Are you sure?" dialog
- Messages instead of empty screens

## Screenshots
(Add at least 4: Vote screen, a refused vote, Results with a winner, Results with a tie, Candidates screen)

## Think answers

**1. Why must names be cleaned before they are compared?**
If we compare the raw text, `aline` and `ALINE ` look like two different people, so the same person could vote twice. Cleaning first makes them both `Aline`, so the app sees they are the same voter.

**2. How does the app decide between a winner and a tie?**
It sorts the candidates from most votes to least. Then it takes the top score and collects every candidate who has exactly that score. If only one candidate has it, he or she is the winner. If two or more have it, the banner says there is a tie between them.

## How to run
1. Open this folder in VS Code.
2. In the terminal, run `flutter create .` (once, it adds the android/ios/web folders).
3. Run `flutter pub get`, then `flutter run`.
