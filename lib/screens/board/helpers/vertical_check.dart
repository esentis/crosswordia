import 'package:crosswordia/core/extensions/map_extensions.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:crosswordia/services/models/word_placement_data.dart';
import 'package:string_extensions/string_extensions.dart';

bool canStartVertically(WordPlacementData data) {
  // This is the VERTICAL starting point of the word IF it can be placed
  final int actualVerticalRow =
      data.actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

  // Checking if there is enough space to the bottom & top
  if (data.spaceFromTop < data.distanceFromTopOfLetter ||
      data.spaceFromBottom < data.distanceFromBottomOfLetter ||
      actualVerticalRow < 1) {
    return false;
  }

  final int verticalRowIterator = actualVerticalRow;

  final int actualStartingRowInt =
      data.actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

  bool hasActualConflicts = false;

  // if (word == 'ΦΑΕ') {
  //   kLog.i('Looking for $letter in $location for vertical availability');
  // }
  // Iterating through the word to check if there are any conflicts
  for (var k = 0; k < data.word.length; k++) {
    // If we are at the end of the board, we break
    if (actualStartingRowInt + k > 10 ||
        verticalRowIterator + k - 1 >
            data.actualVerticalEndingLocationIfAvailable.before('.').toInt()!) {
      break;
    }
    // Main location to check
    final String locationToCheck = '${verticalRowIterator + k}.${data.colInt}';

    // Locations to check to the left and right
    final String beforeStartWordLetterLocation =
        '${actualVerticalRow - data.distanceFromTopOfLetter}.${data.colInt}';
    final String afterEndWordLetterLocation =
        '${actualVerticalRow + data.distanceFromBottomOfLetter}.${data.colInt}';

    final String leftLocationToCheck =
        '${verticalRowIterator + k}.${data.colInt - 1}';
    final String leftBottomLocationToCheck =
        '${verticalRowIterator + k + 1}.${data.colInt - 1}';
    final String leftTopLocationToCheck =
        '${verticalRowIterator + k - 1}.${data.colInt - 1}';

    final String rightLocationToCheck =
        '${verticalRowIterator + k}.${data.colInt + 1}';
    final String rightBottomLocationToCheck =
        '${verticalRowIterator + k + 1}.${data.colInt + 1}';
    final String rightTopLocationToCheck =
        '${verticalRowIterator + k - 1}.${data.colInt + 1}';

    final String topLocationToCheck =
        '${verticalRowIterator + k - 1}.${data.colInt}';
    final String bottomLocationToCheck =
        '${verticalRowIterator + k + 1}.${data.colInt}';

    final bool isRightBottomOutOfReach =
        rightBottomLocationToCheck.before('.').toInt()! >
            data.actualVerticalEndingLocationIfAvailable.before('.').toInt()!;
    final bool isLeftBottomOutOfReach =
        leftBottomLocationToCheck.before('.').toInt()! >
            data.actualVerticalEndingLocationIfAvailable.before('.').toInt()!;

    final bool isRightTopOutOfReach =
        rightTopLocationToCheck.before('.').toInt()! <
            data.actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

    final bool isLeftTopOutOfReach =
        leftTopLocationToCheck.before('.').toInt()! <
            data.actualVerticalStartingLocationIfAvailable.before('.').toInt()!;

    final hasConflicts = () {
      // This is the letter of the location we are checking
      // If it is empty, it means that there is no letter in the location
      final String checkingLetter = data.word.charAt(k);

      final String currentLocationLetter = data.letterPositions
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
          data.word.charAt(k) == currentLocationLetter;

      final bool currentLocationHasConflict =
          (data.letterPositions.anyValue((v) => v.contains(locationToCheck)) &&
                  locationToCheck != data.location) ||
              (currentLocationLetter.isEmpty &&
                      data.letterPositions.anyValue(
                        (value) => value.contains(rightLocationToCheck),
                      ) ||
                  currentLocationLetter.isEmpty &&
                      data.letterPositions.anyValue(
                        (value) => value.contains(leftLocationToCheck),
                      ));

      final bool afterEndHasConflicts = data.letterPositions.anyValue(
        (v) => v.contains(data.actualVerticalAfterEndingLocationIfAvailable),
      );

      final bool beforeStartHasConflicts = data.letterPositions.anyValue(
        (v) => v.contains(data.actualVerticalBeforeStartingLocationIfAvailable),
      );

      final bool leftTopLocationHasConflict = (data.letterPositions.anyValue(
                (v) => v.contains(leftTopLocationToCheck),
              ) &&
              data.actualVerticalStartingLocationIfAvailable
                      .before('.')
                      .toInt()! <=
                  leftTopLocationToCheck.before('.').toInt()!) &&
          data.letterPositions.anyValue(
            (v) => v.contains(leftLocationToCheck),
          );

      final bool rightLocationHasConflict = (data.letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              ) &&
              data.letterPositions.anyValue(
                (v) => v.contains(rightTopLocationToCheck),
              ) &&
              !isRightTopOutOfReach) ||
          (data.letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              ) &&
              data.letterPositions.anyValue(
                (v) => v.contains(rightBottomLocationToCheck),
              ) &&
              !isRightBottomOutOfReach) ||
          (!isCurrentLetterPartOfTheWord &&
                  locationToCheck ==
                      data.actualVerticalEndingLocationIfAvailable) &&
              data.letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              ) ||
          checkingLetter.isEmpty &&
              data.letterPositions.anyValue(
                (v) => v.contains(rightLocationToCheck),
              );

      final bool leftLocationHasConflict = (data.letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              ) &&
              data.letterPositions.anyValue(
                (v) => v.contains(leftTopLocationToCheck),
              ) &&
              !isLeftTopOutOfReach) ||
          (data.letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              ) &&
              data.letterPositions.anyValue(
                (v) => v.contains(leftBottomLocationToCheck),
              ) &&
              !isLeftBottomOutOfReach) ||
          (!isCurrentLetterPartOfTheWord &&
                  locationToCheck ==
                      data.actualVerticalStartingLocationIfAvailable) &&
              data.letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              ) ||
          checkingLetter.isEmpty &&
              data.letterPositions.anyValue(
                (v) => v.contains(leftLocationToCheck),
              );

      if (data.word == 'ΖΕΑ' &&
          data.actualVerticalStartingLocationIfAvailable == '1.8') {
        kLog.f('''
Actual vertical row $actualVerticalRow

Letter ${data.letter} letterIndex ${data.letterIndex}

First check ${data.letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                ) && data.letterPositions.anyValue(
                  (v) => v.contains(leftTopLocationToCheck),
                )}

Second check ${data.letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                ) && data.letterPositions.anyValue(
                  (v) => v.contains(leftBottomLocationToCheck),
                )}

What is this ${(!isCurrentLetterPartOfTheWord && locationToCheck == data.actualVerticalStartingLocationIfAvailable) && data.letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                )}

Or this ${checkingLetter.isEmpty && data.letterPositions.anyValue(
                  (v) => v.contains(leftLocationToCheck),
                )}
              
Current letter part of the word $isCurrentLetterPartOfTheWord
Checking letter is null ${checkingLetter.isEmpty}

Left location has character ${data.letterPositions.anyValue((v) => v.contains(leftLocationToCheck))}
Left top location has character ${data.letterPositions.anyValue((v) => v.contains(leftTopLocationToCheck))}
Left bottom location has character ${data.letterPositions.anyValue((v) => v.contains(leftBottomLocationToCheck))}

Right location has character ${data.letterPositions.anyValue((v) => v.contains(rightLocationToCheck))}
Right top location has character ${data.letterPositions.anyValue((v) => v.contains(rightTopLocationToCheck))}
Right bottom location has character ${data.letterPositions.anyValue((v) => v.contains(rightBottomLocationToCheck))}

k is $k
Letter is ${data.letter}
Iterating over letter ${data.word.charAt(k)}
data.word.charAt(k) != checkingLocationLetter ${data.word.charAt(k) != checkingLetter}
Possible start ${data.actualVerticalStartingLocationIfAvailable}
Possible end ${data.actualVerticalEndingLocationIfAvailable}
Before start $beforeStartWordLetterLocation actual ${data.actualVerticalBeforeStartingLocationIfAvailable}
After end $afterEndWordLetterLocation actual ${data.actualVerticalAfterEndingLocationIfAvailable}

locationToCheck $locationToCheck
locationToCheck letter $currentLocationLetter is it part of the word ? $isCurrentLetterPartOfTheWord
location ${data.location}


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

letterIndex${data.letterIndex} != word.length${data.word.length} ${data.letterIndex != data.word.length}

Before start conflict $beforeStartHasConflicts
After end conflict $afterEndHasConflicts
Current location conflict $currentLocationHasConflict

--- Conflicts ---
Space from top ${data.spaceFromTop}
Space from bottom ${data.spaceFromBottom}
Distance from top of intersection ${data.distanceFromTopOfLetter}
Distance from bottom ${data.distanceFromBottomOfLetter}

All letter positions:
${data.letterPositions}

Found locations
${data.foundLocations}
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
