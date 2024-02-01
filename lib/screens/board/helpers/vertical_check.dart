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
      actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

  // Checking if there is enough space to the bottom & top
  if (spaceFromTop < distanceFromTopOfLetter ||
      spaceFromBottom < distanceFromBottomtOfLetter ||
      actualVerticalRow < 1) {
    return false;
  }

  final int verticalRowIterator = actualVerticalRow;

  final int actualStartingRowInt =
      actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

  bool hasActualConflicts = false;

  // if (word == 'ΦΑΕ') {
  //   kLog.i('Looking for $letter in $location for vertical availability');
  // }
  // Iterating through the word to check if there are any conflicts
  for (var k = 0; k < word.length; k++) {
    // If we are at the end of the board, we break
    if (actualStartingRowInt + k > 10 ||
        verticalRowIterator + k - 1 >
            actualVerticalEndingLocationIfAvailable.before('.').toInt()!) {
      break;
    }
    // Main location to check
    final String locationToCheck = '${verticalRowIterator + k}.$col';

    // Locations to check to the left and right
    final String beforeStartWordLetterLocation =
        '${actualVerticalRow - distanceFromTopOfLetter}.$colInt';
    final String afterEndWordLetterLocation =
        '${actualVerticalRow + distanceFromBottomtOfLetter}.$colInt';

    final String leftLocationToCheck =
        '${verticalRowIterator + k}.${colInt - 1}';
    final String leftBottomLocationToCheck =
        '${verticalRowIterator + k + 1}.${colInt - 1}';
    final String leftTopLocationToCheck =
        '${verticalRowIterator + k - 1}.${colInt - 1}';

    final String rightLocationToCheck =
        '${verticalRowIterator + k}.${colInt + 1}';
    final String rightBottomLocationToCheck =
        '${verticalRowIterator + k + 1}.${colInt + 1}';
    final String rightTopLocationToCheck =
        '${verticalRowIterator + k - 1}.${colInt + 1}';

    final String topLocationToCheck = '${verticalRowIterator + k - 1}.$colInt';
    final String bottomLocationToCheck =
        '${verticalRowIterator + k + 1}.$colInt';

    final bool isRightBottomOutOfReach =
        rightBottomLocationToCheck.before('.').toInt()! >
            actualVerticalEndingLocationIfAvailable.before('.').toInt()!;
    final bool isLeftBottomOutOfReach =
        leftBottomLocationToCheck.before('.').toInt()! >
            actualVerticalEndingLocationIfAvailable.before('.').toInt()!;

    final bool isRightTopOutOfReach =
        rightTopLocationToCheck.before('.').toInt()! <
            actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

    final bool isLeftTopOutOfReach =
        leftTopLocationToCheck.before('.').toInt()! <
            actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

    final hasConflicts = () {
      // This is the letter of the location we are checking
      // If it is empty, it means that there is no letter in the location
      final String checkingLetter = word.charAt(k);

      final String currentLocationLetter = letterPositions
          .whereValue(
            (value) => value.contains(locationToCheck),
            orElse: () => {"": []},
          )
          .entries
          .first
          .key;

      // If there is a letter in the location and it is
      // included in the word, we return true
      final bool isCurrentLetterPartOfTheWord =
          word.charAt(k) == currentLocationLetter;

      final bool currentLocationHasConflict =
          (letterPositions.anyValue((v) => v.contains(locationToCheck)) &&
                  locationToCheck != location) ||
              (currentLocationLetter.isEmpty &&
                      letterPositions.anyValue(
                        (value) => value.contains(rightLocationToCheck),
                      ) ||
                  currentLocationLetter.isEmpty &&
                      letterPositions.anyValue(
                        (value) => value.contains(leftLocationToCheck),
                      ));

      final bool afterEndHasConflicts = letterPositions.anyValue(
        (v) => v.contains(actualVerticalAfterEndingLocationIfAvailable),
      );

      final bool beforeStartHasConflicts = letterPositions.anyValue(
        (v) => v.contains(actualVerticalBeforeStartingLocationIfAvailable),
      );

      final bool leftTopLocationHasConflict = (letterPositions.anyValue(
                (v) => v.contains(leftTopLocationToCheck),
              ) &&
              actualVerticalStartingLocationIfAvailable.before('.').toInt()! <=
                  leftTopLocationToCheck.before('.').toInt()!) &&
          letterPositions.anyValue(
            (v) => v.contains(leftLocationToCheck),
          );

      final bool rightLocationHasConflict = (letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              ) &&
              letterPositions.anyValue(
                (v) => v.contains(rightTopLocationToCheck),
              ) &&
              !isRightTopOutOfReach) ||
          (letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              ) &&
              letterPositions.anyValue(
                (v) => v.contains(rightBottomLocationToCheck),
              ) &&
              !isRightBottomOutOfReach) ||
          (!isCurrentLetterPartOfTheWord &&
                  locationToCheck == actualVerticalEndingLocationIfAvailable) &&
              letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              ) ||
          checkingLetter.isEmpty &&
              letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              );

      final bool leftLocationHasConflict = (letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              ) &&
              letterPositions.anyValue(
                (v) => v.contains(leftTopLocationToCheck),
              ) &&
              !isLeftTopOutOfReach) ||
          (letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              ) &&
              letterPositions.anyValue(
                (v) => v.contains(leftBottomLocationToCheck),
              ) &&
              !isLeftBottomOutOfReach) ||
          (!isCurrentLetterPartOfTheWord &&
                  locationToCheck ==
                      actualVerticalStartingLocationIfAvailable) &&
              letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              ) ||
          checkingLetter.isEmpty &&
              letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              );

      if (word == 'ΖΕΑ' && actualVerticalStartingLocationIfAvailable == '1.8') {
        kLog.f('''
Actual vertical row $actualVerticalRow

Letter $letter letterIndex $letterIndex

First check ${letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                ) && letterPositions.anyValue(
                  (v) => v.contains(leftTopLocationToCheck),
                )}

Second check ${letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                ) && letterPositions.anyValue(
                  (v) => v.contains(leftBottomLocationToCheck),
                )}
              
What is this ${(!isCurrentLetterPartOfTheWord && locationToCheck == actualVerticalStartingLocationIfAvailable) && letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                )}

Or this ${checkingLetter.isEmpty && letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                )}
              
Current letter part of the word $isCurrentLetterPartOfTheWord
Checking letter is null ${checkingLetter.isEmpty}

Left location has character ${letterPositions.anyValue((v) => v.contains(leftLocationToCheck))}
Left top location has character ${letterPositions.anyValue((v) => v.contains(leftTopLocationToCheck))}
Left bottom location has character ${letterPositions.anyValue((v) => v.contains(leftBottomLocationToCheck))}

Right location has character ${letterPositions.anyValue((v) => v.contains(rightLocationToCheck))}
Right top location has character ${letterPositions.anyValue((v) => v.contains(rightTopLocationToCheck))}
Right bottom location has character ${letterPositions.anyValue((v) => v.contains(rightBottomLocationToCheck))}

k is $k
Letter is $letter
Iterating over letter ${word.charAt(k)}
word.charAt(k) != checkingLocationLetter ${word.charAt(k) != checkingLetter}
Possible start $actualVerticalStartingLocationIfAvailable
Possible end $actualVerticalEndingLocationIfAvailable
Before start $beforeStartWordLetterLocation actual $actualVerticalBeforeStartingLocationIfAvailable
After end $afterEndWordLetterLocation actual $actualVerticalAfterEndingLocationIfAvailable

locationToCheck $locationToCheck
locationToCheck letter $currentLocationLetter is it part of the word ? $isCurrentLetterPartOfTheWord
location $location
Intersection location $location


--- Conflicts ---
Is right bottom ($rightBottomLocationToCheck) out of reach $isRightBottomOutOfReach
Is left bottom ($leftBottomLocationToCheck) out of reach $isLeftBottomOutOfReach
Is right top ($rightTopLocationToCheck) out of reach $isRightTopOutOfReach
Is left top ($leftTopLocationToCheck) out of reach $isLeftTopOutOfReach

Top location $topLocationToCheck conflict
Bottom location $bottomLocationToCheck conflict

Left location $leftLocationToCheck conflict $leftLocationHasConflict
Left top location $leftTopLocationToCheck conflict $leftTopLocationHasConflict
Left bottom location $leftBottomLocationToCheck conflict leftBottomLocationHasConflict

Right location $rightLocationToCheck conflict $rightLocationHasConflict
Right top location $rightTopLocationToCheck conflict - 
Right bottom location $rightBottomLocationToCheck conflict rightBottomLocationHasConflict

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
      return currentLocationHasConflict ||
          afterEndHasConflicts ||
          beforeStartHasConflicts ||
          leftLocationHasConflict ||
          leftTopLocationHasConflict ||
          rightLocationHasConflict ||
          beforeStartHasConflicts ||
          afterEndHasConflicts;
    }.call();

    // log.f(locationToCheck);
    hasActualConflicts = hasConflicts;
    if (hasActualConflicts) {
      //  if (word == 'ΤΥΡΙ') kLog.f('Breaking at $locationToCheck with k $k');
      break;
    }
  }
  return !hasActualConflicts;
}
