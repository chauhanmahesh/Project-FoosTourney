# FoosTourney

This project is part of Udacity's 'iOS Nanodegree Programme' final submission.

## Introduction:

'FoosTourney' is a iOS mobile app meant for Foosball players to easily organize a tournament within organization/group and to keep a record of matches, teams and score.

Many times in organization like ours we have many individuals who are interested in foodball and want to organize a tournament within a company. And always the hard part in doing that is choose someone who will bear all the headache of choosing random teams and tracking matches in a speadsheet and scores and eventaully deciding the winner based on points standings.
This app will basically totally removes that neccessity of that individual and it does all that by itself and any player can basically create the tournament.

All the scores and list of matches and what is the current standings and winner is right below your tips.

## Features:

### Authentication:

- Login via google so that authentication is secure and hassle - free. (FirebaseAuth is used for that integration)

### Groups:

- Can create multiple groups within organization or among different friends.
- Let's you choose a group for which you want to create a tournament.

### Tournaments:

- Can create 'Singles' or 'Doubles' tournaments.
- Select any number of players. (For doubles it has to even so that proper teams can be generated.)
- Fancy team names generated randomly for each team (in doubles) so that you don't have to think hard to choose a team name.
- Randomly generates the teams so you don't have to draw the chits and don't have to worry about biased team selection. All is random.

### Fancy Stats:

- Shows standings for each tournament and shows who is running as winner as per the points.
- Shows user stats in your profile and tells you how good/bad you are 🤗

### Simple and Minimalistic UI

- Very simple UI so that you don't have to pull your hair understanding what app does. 😁
- Fully supports iOS Dark Mode as well 🖤🎉

## Storyboard Representation

Below is the storyboard representation of the app.

![Storyboard Representation](https://drive.google.com/uc?export=view&id=1yVcquEkLAC7Ezthh4C9YLueobT8Uxw0y)

## Screens Flow

### App launch (First Time)

- Launch the app by tapping on FoosTourney app icon

  <img src="https://drive.google.com/uc?export=view&id=1yh_uOx0dnad3MW3l5-IscTRahX-FAt84" width="150"> -> <img src="https://drive.google.com/uc?export=view&id=12Qit3TUrmMFF_RtaRi3GoaUNwm0Z82ok" width="150">

### Login

- If you are never logged in then it will ask you to login.
  Enter your google account details and login.

  <img src="https://drive.google.com/uc?export=view&id=1c5bo3AUSTso3EIzACN9fWjjr1qUFArfG" width="150"> -> <img src="https://drive.google.com/uc?export=view&id=10PCa09ouUpXT_AWgPNnmW3lzsJThKbkk" width="150">

### Group Selection

- When you will login for the first time and you are not part of any group then you have to select a group (from the list of your already belongs to) else you can search for any existing groups in Foostourney or you can create a new one.

  <img src="https://drive.google.com/uc?export=view&id=1M1ll9EDrT2URFjDAL70rdkXaSfnUi2Ph" width="150">

  If you see above screen means you are not part of any group yet. Tap on Search icon on top left to join any existing Groups.
  Enter 'Udacity' (as this group already exists) to search group. And when displayed tap on 'Join' button.

  <img src="https://drive.google.com/uc?export=view&id=1-RY6NQ0cIhHdwwK09IgX3uMzcRX3lBz1" width="150">

  Now cancel this screen and tap on "Udacity" group in group selection page.

  <img src="https://drive.google.com/uc?export=view&id=1CgKhVllBWHSoHvJsHoT175g0ABSTgaoD" width="150">

### Dashboard

- If there is already some tournament exists within a group then it will show a list of tournaments with their current status. i.e. "In Progress" or "Complete"

  Note: There are some tournaments already created within "Udacity Group"

  <img src="https://drive.google.com/uc?export=view&id=1tBldOhpsOLCTxj-PjkoNvXBBBQcLDDnM" width="150">

### Tournament Dashboard

- Tapping on a particular tournament will lead you to Tournament Dashboard where you can see a list of matches and a standings table.
  If the match is already scored then it will show a score against a team or a player (singles). If match is not scored yet then tapping on row will lead to "Record Score" page where you can record the score of a match.

  If the match is already score then it shows trophy symbol (🏆) in front of the winner team or player (Singles)

  Note: The points given to a team/player when they won a match is based on this formula:

  (2 points for a win) + (Goals difference)

  So if player/team won a game with score 10 -> 2 then they will get (2 + 8) = 10 points.

  <img src="https://drive.google.com/uc?export=view&id=1BaPvx_3jgkF6GH5V7q7eQncWYbFlNYc-" width="150"> <img src="https://drive.google.com/uc?export=view&id=1OR7PgvcSRsY_Bc-ykd9_lYbe_qlR3lQQ" width="150">

### Record Score

- As mentioned above, tapping on a unscored match will show a record score screen which lets you save the match score.
  After selecting score for each team/player, tap on 'Save'/

  <img src="https://drive.google.com/uc?export=view&id=1u4EBT6DPM9ny0I4cz94dBge5fWW2defr" width="150">

### Create Tournament

- If you want to create a new tournament then a tournament can be created by tapping on '+' icon on top right on the tournament tab.

  Steps:

  1. Enter Tournament Name. Choose Tournament type (singles/doubles)
  2. Select players which you want to be in tournament. Tap on "Generate Teams" (for doubles) or "Generate Matches" (for singles)
  3. Tap on "Start Tournament" on generated matches screens to start the tournament.

  <img src="https://drive.google.com/uc?export=view&id=12MBht8j4FBIHmlNfKo5LN6jppkm3kE-2" width="150"> -> <img src="https://drive.google.com/uc?export=view&id=1sBYRbwRjMEsxCT746lUMmsvBVi9kT8PX" width="150"> -> <img src="https://drive.google.com/uc?export=view&id=1kShM5gFT5wHCZ9snMyscl-lzk2m_nhOd" width="150"> -> <img src="https://drive.google.com/uc?export=view&id=1ZFlSAugRtp1VG9jHi16pRsNVllLuoi5J" border = "1" border-color = "black" width="150">

### Profile

- Tap on 'Profile' tab to check the profile screen. It displays a stats for a authenticated user. The details which it shows is:

  1. How many matches user played.
  2. How many matches user won.
  3. What's the win %.

- These stats are based on number of matches user played across any tournaments / groups.

  <img src="https://drive.google.com/uc?export=view&id=1ak_ffhkkPSZPoA3vOZ0afPYOUeo3-ZkT" width="150" border="1">
