# Places Anniversaries


## Description
- Places Anniversaries is an iOS and iPadOS app the let users add places, each with some anniversaries.
- Initially if database has some places added already, users can scroll through them.
- Each listed place displays photo, name, and list of anniversaries.
- Users can pick a place and open it in a different view, where they can edit place image, name and add or delete anniversaries.
- When users open place map view, they can change place location through the map view itself.
- For a user to add a new anniversary, the need to give it both, a name and date.
- When users tap "+" button to add a new place, app will direct them step by step to fill in all required fields, such as photo, location and at least one anniversary.
- Adding new places has this walkthrough as a good user experience.
- Users can delete places one by one, either by swiping a place right from places list, or be tapping "Edit" button.


## App Features
- Supports iOS 10 and above.
- Supports Dark and Light modes on iOS 13.
- Supports iPhone portrait orientation.
- Supports iPad landscape right and left orientations as well as upside down. 


##### Notes
- App automatically and anonymously signs to Firebase.
- Signing in to Firebase was made mandatory in order to secure read and write permissions for both CloudStore and Storage.
- Pagination was implemented although it isn't directly supported by Firebase CloudStore.
- Pods are included for testing purpose.
- Classes, methods and variables are documented for clarification (only the ones that need clarification).
- Built with Xcode 11.1.
- Does not support multiple windows.
- Requires full screen.
