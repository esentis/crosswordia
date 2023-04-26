import 'package:crosswordia/helper.dart';
import 'package:string_extensions/string_extensions.dart';

bool canStartVertically({
  required int distanceFromTopOfLetter,
  required int distanceFromBottomtOfLetter,
  required int spaceFromTop,
  required int spaceFromBottom,
  required String actualVerticalStartingLocationIfAvailable,
  required String actualVerticalEndingLocationIfAvailable,
  required String word,
  required String col,
  required String location,
  required String actualVerticalBeforeStartingLocationIfAvailable,
  required String actualVerticalAfterEndingLocationIfAvailable,
  required int rowInt,
  required int colInt,
  required Map<String, List<String>> letterPositions,
  required String letter,
  required int letterIndex,
  required List<String> foundLocations,
}) {
  // This is the VERTICAL starting point of the word IF it can be placed
  final int actualVerticalRow =
      actualVerticalStartingLocationIfAvailable.before('.')!.toInt()!;

  // Checking if there is enough space to the bottom & top
  if (spaceFromTop < distanceFromTopOfLetter ||
      spaceFromBottom < distanceFromBottomtOfLetter ||
      actualVerticalRow < 1) {
    if (word == 'ΑΜΑ' && actualVerticalStartingLocationIfAvailable == '8.10') {
      kLog.e('Breaking due to dinstance issues');
    }

    return false;
  }

  int verticalRowIterator = actualVerticalRow;

  int actualStartingRowInt =
      actualVerticalStartingLocationIfAvailable.before('.')!.toInt()!;

  bool hasActualConflicts = false;

  // if (word == 'ΦΑΕ') {
  //   kLog.i('Looking for $letter in $location for vertical availability');
  // }
  // Iterating through the word to check if there are any conflicts
  for (var k = 0; k < word.length; k++) {
    if (word == 'ΑΜΑ' && actualVerticalStartingLocationIfAvailable == '8.10') {
      kLog.wtf('Location checking is ${verticalRowIterator + k}.$col');
    }
    // If we are at the end of the board, we break
    if (actualStartingRowInt + k > 10 ||
        verticalRowIterator + k - 1 >
            actualVerticalEndingLocationIfAvailable.before('.').toInt()!) {
      if (word == 'ΑΜΑ' &&
          actualVerticalStartingLocationIfAvailable == '8.10') {
        kLog.e(
            'row int is $actualStartingRowInt\nverticalRowIterator is $verticalRowIterator\nk is $k\nactualVerticalEndingLocationIfAvailable is $actualVerticalEndingLocationIfAvailable');
      }
      break;
    }
    // Main location to check
    String locationToCheck = '${verticalRowIterator + k}.$col';

    // if (word == 'ΑΤΙ') {
    //   kLog.wtf(
    //       'row ${verticalRowIterator + k} checking location of tyri $locationToCheck');
    // }
    // Locations to check to the left and right
    String beforeStartWordLetterLocation =
        '${actualVerticalRow - distanceFromTopOfLetter}.$colInt';
    String afterEndWordLetterLocation =
        '${actualVerticalRow + distanceFromBottomtOfLetter}.$colInt';

    String leftLocationToCheck = '${verticalRowIterator + k}.${colInt - 1}';
    String leftBottomLocationToCheck =
        '${verticalRowIterator + k + 1}.${colInt - 1}';
    String leftTopLocationToCheck =
        '${verticalRowIterator + k - 1}.${colInt - 1}';

    String rightLocationToCheck = '${verticalRowIterator + k}.${colInt + 1}';
    String rightBottomLocationToCheck =
        '${verticalRowIterator + k + 1}.${colInt + 1}';
    String rightTopLocationToCheck =
        '${verticalRowIterator + k - 1}.${colInt + 1}';

    String topLocationToCheck = '${verticalRowIterator + k - 1}.$colInt';
    String bottomLocationToCheck = '${verticalRowIterator + k + 1}.$colInt';

    final hasConflicts = letterPositions.any(
      (key, value) {
        final letterOfCheckingLocationMap = letterPositions.whereKey(
          (key_) => key_ == word.charAt(k),
          () => {},
        );

        final String? checkingLocationLetter =
            letterOfCheckingLocationMap.isNotEmpty
                ? letterOfCheckingLocationMap.keys.first
                : null;

        final bool isCurrentLetterPartOfTheWord =
            word.charAt(k) == checkingLocationLetter;

        final bool currentLocationHasAlreadyDifferentLetter = () {
          final lettersOfThePosition = letterPositions
              .whereValue(
                (value) => value.contains(locationToCheck),
                orElse: () => {},
              )
              .entries;

          if (lettersOfThePosition.isNotEmpty) {
            return lettersOfThePosition.first.key != checkingLocationLetter;
          }

          return false;
        }.call();

        if (word == 'ΠΑΝΕ' &&
            actualVerticalStartingLocationIfAvailable == '5.8') {
          kLog.d(
            'Letter of the position $locationToCheck ${letterPositions.whereValue(
                  (value) => value.contains(locationToCheck),
                ).entries.first.key}',
          );
          kLog.d(
              'Has different current letter $currentLocationHasAlreadyDifferentLetter');
        }

        final bool currentLocationHasConflict =
            (value.contains(locationToCheck) &&
                    locationToCheck != location &&
                    !isCurrentLetterPartOfTheWord &&
                    (locationToCheck == actualVerticalEndingLocationIfAvailable
                        ? key != word.charAt(word.length - 1)
                        : key != word.charAt(letterIndex))) ||
                currentLocationHasAlreadyDifferentLetter;

        final bool afterEndHasConflicts =
            value.contains(actualVerticalAfterEndingLocationIfAvailable);

        final bool beforeStartHasConflicts =
            value.contains(beforeStartWordLetterLocation);

        final bool leftTopLocationHasConflict = (letterPositions.anyValue(
                  (v) => v.contains(leftTopLocationToCheck),
                ) &&
                actualVerticalStartingLocationIfAvailable
                        .before('.')!
                        .toInt()! <=
                    leftTopLocationToCheck.before('.')!.toInt()!) &&
            letterPositions.anyValue(
              (v) => v.contains(leftLocationToCheck),
            );

        final bool rightBottomLocationHasConflict = (letterPositions.anyValue(
              (v) => v.contains(rightBottomLocationToCheck),
            ) &&
            letterIndex != word.length &&
            letterIndex != word.length - 1);

        final bool leftBottomLocationHasConflict = (letterPositions.anyValue(
              (v) => v.contains(leftBottomLocationToCheck),
            ) &&
            (letterPositions.anyValue(
              (v) => v.contains(leftLocationToCheck),
            )) &&
            letterIndex != word.length &&
            letterIndex != word.length - 1);

        final bool leftLocationHasConflict =
            (value.contains(leftLocationToCheck) &&
                locationToCheck != location);

        final bool rightLocationHasConflict = (letterPositions.anyValue(
                  (v) => v.contains(rightLocationToCheck),
                ) &&
                letterPositions.anyValue(
                  (v) => v.contains(rightTopLocationToCheck),
                )) ||
            (letterPositions.anyValue(
                  (v) => v.contains(rightLocationToCheck),
                ) &&
                letterPositions.anyValue(
                  (v) => v.contains(rightBottomLocationToCheck),
                )) ||
            (!isCurrentLetterPartOfTheWord &&
                    locationToCheck ==
                        actualVerticalEndingLocationIfAvailable) &&
                letterPositions.anyValue(
                  (v) => v.contains(rightLocationToCheck),
                );

        if (word == 'ΒΑΤ' &&
            actualVerticalStartingLocationIfAvailable == '4.6') {
          kLog.wtf('''
Actual vertical row $actualVerticalRow

Letter $letter letterIndex $letterIndex
The letter map is $letterOfCheckingLocationMap
Current k $k
Current key is $letter
Iterating over letter ${word.charAt(k)}
word.charAt(k) != checkingLocationLetter ${word.charAt(k) != checkingLocationLetter}
Possible start $actualVerticalStartingLocationIfAvailable
Possible end $actualVerticalEndingLocationIfAvailable
Before start $beforeStartWordLetterLocation actual $actualVerticalBeforeStartingLocationIfAvailable
After end $afterEndWordLetterLocation actual $actualVerticalAfterEndingLocationIfAvailable

locationToCheck $locationToCheck
locationToCheck letter $checkingLocationLetter is it part of the word ? $isCurrentLetterPartOfTheWord
location $location
Intersection location $location
letter positions $value

--- Conflicts ---
Top location $topLocationToCheck conflict
Bottom location $bottomLocationToCheck conflict

Left location $leftLocationToCheck conflict $leftLocationHasConflict
Left top location $leftTopLocationToCheck conflict $leftTopLocationHasConflict
Left bottom location $leftBottomLocationToCheck conflict $leftBottomLocationHasConflict

Right location $rightLocationToCheck conflict $rightLocationHasConflict
Right top location $rightTopLocationToCheck conflict - 
Right bottom location $rightBottomLocationToCheck conflict $rightBottomLocationHasConflict

First condition (${((value.contains(locationToCheck) && locationToCheck != location && !isCurrentLetterPartOfTheWord))})
letterIndex$letterIndex != word.length${word.length} ${letterIndex != word.length}

Before start conflict $beforeStartHasConflicts
After end conflict $afterEndHasConflicts
Current location conflict $currentLocationHasConflict

--- Conflicts ---
Space from top $spaceFromTop
Space from bottom $spaceFromBottom
Distance from top of intersection $distanceFromTopOfLetter
Distance from bottom $distanceFromBottomtOfLetter

All letter positions:
$letterPositions

Found locations
$foundLocations
''');
        }
        return ((value.contains(locationToCheck) &&
                locationToCheck != location &&
                !isCurrentLetterPartOfTheWord) ||
            currentLocationHasConflict ||
            afterEndHasConflicts ||
            beforeStartHasConflicts ||
            leftLocationHasConflict ||
            leftTopLocationHasConflict ||
            rightLocationHasConflict ||
            rightBottomLocationHasConflict ||
            leftBottomLocationHasConflict ||
            (value.contains(actualVerticalBeforeStartingLocationIfAvailable) ||
                value.contains(actualVerticalAfterEndingLocationIfAvailable)));
      },
    );
    // log.wtf(locationToCheck);
    hasActualConflicts = hasConflicts;
    if (hasActualConflicts) {
      //  if (word == 'ΤΥΡΙ') kLog.wtf('Breaking at $locationToCheck with k $k');
      break;
    }
  }
  return !hasActualConflicts;
}
