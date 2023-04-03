import 'package:crosswordia/helper.dart';
import 'package:string_extensions/string_extensions.dart';

bool canStartHorizontally({
  required int distanceFromRightOfLetter,
  required int distanceFromLeftOfLetter,
  required int spaceFromLeft,
  required int spaceFromRight,
  required String word,
  required String col,
  required String location,
  required String actualHorizontalStartingLocationIfAvailable,
  required String actualHorizontalEndingLocationIfAvailable,
  required String actualVerticalBeforeStartingLocationIfAvailable,
  required String actualVerticalAfterEndingLocationIfAvailable,
  required int rowInt,
  required int colInt,
  required int letterIndex,
  required Map<String, List<String>> letterPositions,
  required List<String> foundLocations,
  required String letter,
}) {
//   if (word == 'ΑΒΕ') {
//     kLog.i('''
// Looking for $letter in $location for horizontal availability
// Space from left $spaceFromLeft & distance from right $distanceFromLeftOfLetter
// Space from right $spaceFromRight & distance from left $distanceFromRightOfLetter
// ''');
//   }

  // Checking if there is enough space to the left & right
  if (spaceFromLeft < distanceFromLeftOfLetter ||
      spaceFromRight < distanceFromRightOfLetter) {
    if (word == 'ΦΑΕ') {
      kLog.e('Looking for $letter in $location has conflict');
    }
    return false;
  }

  // This is the HORIZONTAL starting point of the word IF it can be placed
  final int actualHorizontalCol =
      actualHorizontalStartingLocationIfAvailable.after('.')!.toInt()!;

  int horizontalColIterator = actualHorizontalCol;

  int actualHorizontalRow =
      actualHorizontalStartingLocationIfAvailable.before('.')!.toInt()!;

  bool hasActualConflicts = false;

  for (var k = 0; k < word.length; k++) {
    // If we are at the end of the board, we break
    // if (word == 'ΛΑΒΕ' && row == '8' && col == '7') {
//                   if (word == 'ΑΦΕ') kLog.wtf('''
// Current letter $letter
// Checking at $location
// Current k $k
// Conflict found $row.$col
// $colInt + k($k) > 10 ${colInt + k > 10}
// $actualHorizontalCol + k > 10 ${actualHorizontalCol + k > 10}
// $distanceFromLeftOfLetter - $rowInt == 0 ${distanceFromLeftOfLetter - rowInt == 0}
// $distanceFromLeftOfLetter + $distanceFromLeftOfLetter > ${distanceFromLeftOfLetter + distanceFromLeftOfLetter} ${distanceFromLeftOfLetter + distanceFromLeftOfLetter > word.length}
// $actualHorizontalCol - 1 < 0 ${actualHorizontalCol - 1 < 0}''');

    if (colInt + k > 10 ||
        distanceFromLeftOfLetter - rowInt == 0 ||
        distanceFromLeftOfLetter + distanceFromRightOfLetter > word.length ||
        horizontalColIterator - 1 < 0) {
      if (word == 'ΛΑΕ') {
        kLog.wtf('''Current letter $letter
Checking at $location
''');
      }
      hasActualConflicts = true;
      break;
    }

    // Main location to check
    String locationToCheck = '$rowInt.$horizontalColIterator';
    // Locations to check to the top and bottom
    String topLocationToCheck = '${rowInt - 1}.$horizontalColIterator';
    String topLeftLocationToCheck =
        '${rowInt - 1}.${horizontalColIterator - 1}';
    String topRightLocationToCheck =
        '${rowInt - 1}.${horizontalColIterator + 1}';

    String bottomLocationToCheck = '${rowInt + 1}.$horizontalColIterator';
    String bottomLeftLocationToCheck =
        '${rowInt + 1}.${horizontalColIterator - 1}';
    String bottomRightLocationToCheck =
        '${rowInt + 1}.${horizontalColIterator + 1}';

    // if (word == 'ΦΑΒΑ' &&
    //     actualHorizontalStartingLocationIfAvailable == '9.4')
    //   kLog.wtf(
    //     'Letter $letter position ${i + 1}\nActual horizontal start $actualHorizontalStartingLocationIfAvailable\nDistance from left $distanceFromLeftOfLetter\nDistsance from right $distanceFromRightOfLetter\nTop location to check $topLocationToCheck\nTop left location to check $topLeftLocationToCheck\nTop right location to check $topRightLocationToCheck\nBottom location to check $bottomLocationToCheck\nBottom left location to check $bottomLeftLocationToCheck\nBottom right location to check $bottomRightLocationToCheck\n',
    //   );

    String beforeStartWordLetterLocation =
        '$rowInt.${colInt - distanceFromLeftOfLetter - 1}';

    String afterEndWordLetterLocation =
        '$rowInt.${colInt - distanceFromLeftOfLetter + word.length}';
    // if (word == 'ΛΑΒΕ')
    //   kLog.wtf(
    //       '$letter  before start loc $beforeStartWordLetterLocation aftet start loc $afterEndWordLetterLocation');
    // log.wtf(
    //     '$locationToCheck horizontal col $actualHorizontalCol');
    // // Checking if there are any conflicts, in the main location, or to the top or bottom
    final bool hasConflicts = letterPositions.any(
      (key, value) {
        final letterOfCheckingLocationMap = letterPositions
            .whereValue((value) => value.contains(locationToCheck), orElse: () {
          return {};
        });

        final String? checkingLocationLetter =
            letterOfCheckingLocationMap.isNotEmpty
                ? letterOfCheckingLocationMap.keys.first
                : null;
        final bool isCurrentLetterPartOfTheWord =
            word.charAt(k) == checkingLocationLetter;

        final bool beforeStartHasConflicts = letterPositions
            .anyValue((value) => value.contains(beforeStartWordLetterLocation));

        final bool afterEndHasConflicts =
            value.contains(afterEndWordLetterLocation);

        final bool startingPointHasConflict =
            (value.contains(actualHorizontalStartingLocationIfAvailable) &&
                key != word.charAt(1));

        final bool currentLocationHasConflict =
            (value.contains(locationToCheck) &&
                locationToCheck != location &&
                !isCurrentLetterPartOfTheWord &&
                (locationToCheck == actualHorizontalEndingLocationIfAvailable
                    ? key != word.charAt(word.length - 1)
                    : key != word.charAt(letterIndex)));

        final bool topLeftLocationHasConflict = (letterPositions.anyValue(
              (v) => v.contains(topLeftLocationToCheck),
            ) &&
            locationToCheck != location &&
            beforeStartHasConflicts);
        final bool topRightLocationHasConflict = (letterPositions.anyValue(
              (v) => v.contains(topRightLocationToCheck),
            ) &&
            locationToCheck != location &&
            (letterPositions.anyValue(
              (v) => v.contains(topLocationToCheck),
            )));

        final bool topLocationConflictExtraCheck = !letterPositions.anyValue(
                (value) => value
                    .contains(actualHorizontalStartingLocationIfAvailable)) &&
            letterPositions.anyValue(
              (v) =>
                  v.contains(topLocationToCheck) && locationToCheck != location,
            );

        final bool isTopRightOutOfReach =
            actualHorizontalRow < topRightLocationToCheck.after('.').toInt()!;

        final bool isTopLeftOutOfReach =
            actualHorizontalRow > topLeftLocationToCheck.after('.').toInt()!;

        final bool topLocationHasConflict = ((value
                        .contains(topLocationToCheck) &&
                    locationToCheck != location &&
                    !isCurrentLetterPartOfTheWord) ||
                topLocationConflictExtraCheck && locationToCheck != location) ||
            // If the top right letter cant conflict with the word since it's right of the end. Thus we only check if it conflicts from top left
            (isTopRightOutOfReach
                ? topLeftLocationHasConflict
                : isTopLeftOutOfReach
                    ? topRightLocationHasConflict
                    : topLeftLocationHasConflict &&
                        topRightLocationHasConflict);

        final bool bottomLeftLocationHasConflict = (letterPositions.anyValue(
          (v) => v.contains(bottomLeftLocationToCheck),
        ));
        final bool bottomRightLocationHasConflict = letterPositions.anyValue(
          (v) => v.contains(bottomRightLocationToCheck),
        );

        final bool isBottomRightOutOfReach = actualHorizontalRow <
            bottomRightLocationToCheck.after('.').toInt()!;
        final bool isBottomLeftOutOfReach =
            actualHorizontalRow > bottomLeftLocationToCheck.after('.').toInt()!;

        final bool bottomLocationHasConflict = letterPositions.anyValue(
              (v) => v.contains(bottomLeftLocationToCheck),
            ) &&
            // If the bottom right letter cant conflict with the word since it's right of the end. Thus we only check if it conflicts from bottom left
            (isBottomRightOutOfReach
                ? bottomLeftLocationHasConflict
                : isBottomLeftOutOfReach
                    ? bottomRightLocationHasConflict
                    : bottomLeftLocationHasConflict &&
                        bottomRightLocationHasConflict);

        if (false && actualHorizontalStartingLocationIfAvailable == '9.5') {
          kLog.wtf('''
Letter $letter letterIndex $letterIndex
Iterating over letter ${word.charAt(k)}
word.charAt(k) != checkingLocationLetter ${word.charAt(k) != checkingLocationLetter}
Possible start $actualHorizontalStartingLocationIfAvailable
Possible end $actualHorizontalEndingLocationIfAvailable
Before start $beforeStartWordLetterLocation
After end $afterEndWordLetterLocation

locationToCheck $locationToCheck
locationToCheck letter $checkingLocationLetter
location $location
Intersection location $location
letter positions $value

--- Conflicts ---
Is bottom right out of reach $isBottomRightOutOfReach
Is bottom left out of reach $isBottomLeftOutOfReach
Is top right out of reach $isTopRightOutOfReach
Is top left out of reach $isTopLeftOutOfReach

Bottom location $bottomLocationToCheck conflict $bottomLocationHasConflict
Bottom left location $bottomLeftLocationToCheck conflict $bottomLeftLocationHasConflict
Bottom right location $bottomRightLocationToCheck conflict $bottomRightLocationHasConflict

Top location $topLocationToCheck conflict $topLocationHasConflict
Top left location $topLeftLocationToCheck conflict $topLeftLocationHasConflict
Top right location $topRightLocationToCheck conflict $topRightLocationHasConflict
Top location extra check $topLocationConflictExtraCheck

Before start conflict $beforeStartHasConflicts
After end conflict $afterEndHasConflicts

Current location conflict $currentLocationHasConflict
--- Conflicts ---
Space from left $spaceFromLeft
Space from right $spaceFromRight
Distance from left $distanceFromLeftOfLetter
Distance from right $distanceFromRightOfLetter

All letter positions: 
$letterPositions

Found locations
$foundLocations
''');
        }

        return currentLocationHasConflict ||
            topLocationHasConflict ||
            bottomLocationHasConflict ||
            beforeStartHasConflicts ||
            afterEndHasConflicts;
      },
    );
    hasActualConflicts = hasConflicts;
    if (hasActualConflicts) break;
    horizontalColIterator++;
  }
  // if (word == 'ΛΑΒΕ' && row == '8' && col == '7') {
  //   kLog.wtf('hasActualConflicts $hasActualConflicts');
  // }
  return !hasActualConflicts;
}
