#set document(title: "Running Breadboard Experiments on Prolific", author: ("Karen Gao", "Eric Feltham"))
#set page(paper: "us-letter", margin: 1in, numbering: "1")
#set text(size: 11pt)
#set heading(numbering: "1.1")
#show raw.where(block: true): it => block(fill: luma(245), inset: 8pt, radius: 3pt, width: 100%, it)

#let shot(name, width: 100%) = align(center, image("media/" + name, width: width))
#let hl(body) = strong(highlight(body))
#let cb = box(width: 0.75em, height: 0.75em, stroke: 0.6pt, baseline: 0.1em)

#align(center)[
  #image("media/image1.png", height: 0.9in)
  #h(1em)
  #image("media/image2.png", height: 1.08in)

  #text(size: 22pt, weight: "bold")[Running Breadboard Experiments on Prolific]

  Authored by Karen Gao \
  Updated by Eric Feltham (#link("mailto:eric.feltham@aya.yale.edu")[eric.feltham\@aya.yale.edu]) \
  Last updated: October 2026
]

#outline(depth: 2)

#pagebreak()

= Introduction

This guide explains how to set up and run experiments you create on Breadboard through Prolific, a platform that recruits users online to participate in research studies. Most steps apply to any study. Examples, server names and screenshots come from a revolution game study, so substitute your own study's values. Two parts are specific to that game and are in appendices: its completion codes (Appendix A) and its bonus script (Appendix B).

Prolific's interface changes periodically. Screenshots of the Prolific site show an earlier layout, so use them to find the right field and rely on the field names in the text.

*Before you start, you need:*

- Breadboard login details for your study's server, and SSH access if you want to watch the logs. Ask your Breadboard administrator for these.
- A Prolific account with a project for the study, and enough funds in the wallet for rewards, bonuses and Prolific's platform fee.
- A study that has been tested on Breadboard (see _Testing Experiments on Breadboard_).

*Terms.* A *player* is a participant as Breadboard sees them (a vertex in the graph, with a player ID). A *participant* is the same person as Prolific sees them (with a participant ID and a submission ID). The guide uses each word on the side where it applies, and the Prolific URL parameters link the two.


= Setting Up Breadboard

+ Go to the URL of your Breadboard game and log in with your credentials.
  - URL (may look something like `https://[BREADBOARD_GAME_NAME].brdbrd.net`)
  - Username
  - Password

  Example:

  #shot("image3.png", width: 2.6in)

  Logging in takes you to Breadboard's console:

  #shot("image4.png", width: 5.6in)

+ Make sure the experiment name is correct. Create a new experiment instance.
  - Note: name the instance to match the internal study name you will enter when setting up Prolific.

  #shot("image5.png", width: 5.7in)

+ Click the *Steps* dialog at the bottom. In the Globals step, set the `DEV` and `SANDBOX` variables to *false*. This may not apply to all experiments.

  #shot("image6.png", width: 5.5in)

+ This step may not apply to all experiments. Make sure the parameters in your study are correct (they are defined in the *Globals* step under *Parameters*). If your study has multiple treatment types, set them in the Steps dialog, click *Save* at the bottom right, and reload the script engine (refresh button at the top right). You may have to refresh your page if it is loading for a while.

  For example, in the revolution game, we change the risk and leader treatments here:

  #shot("image7.png", width: 3.2in)

  #shot("image8.png", width: 3.2in)

+ SSH into the Breadboard server through a terminal to view the experiment's logs. Ask your Breadboard administrator for the port, user and directory for your study; they look like this:

  ```sh
  ssh -p <port> <study>@brdbrd.net
  cd <study directory>
  tail -f nohup.out
  ```

  Your terminal should look something like this afterward:

  #shot("image9.png", width: 3.2in)

Everything is now set up on the Breadboard end. Proceed to Prolific.

#pagebreak()

= Setting Up Prolific

+ Select your project and create a new study. If an instance of your study already exists, you can open it and duplicate it.

  Create a new study:

  #shot("image10.png", width: 5.5in)

  Duplicate a study:

  #shot("image11.png", width: 5.5in)

+ In the study setup, fill in the *Study details* based on what your study needs. Give the study an internal name (visible only to you) that matches the instance name you created in Breadboard.

+ Under *Data collection*, answer *How do you want to collect your data?* with a study link, and enter the URL below in the field *What is the URL of your study?*, changing the bolded numbers to match the client URL of your Breadboard instance. Choose *URL Parameters* as the way to record participant IDs (select "I'll use URL parameters"), so that Prolific appends the participant's IDs.

  #block(inset: (left: 1em))[
    `https://rvl.brdbrd.net/game/`*393*`/`*773*`/prolific?PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}`
  ]

  Prolific:

  #shot("image12.png", width: 5.7in)

  Breadboard console (ignore status STOPPED; your instance should be running):

  #shot("image13.png", width: 5.7in)

+ Under *Audience*, the *Prescreen participants* section is where you add screeners. You probably want to exclude participants from any other instances of your study, using the "Exclude participants from other studies" screener, a custom blocklist, or a participant group used as a blocklist. When you duplicate a previous study instance, its screeners carry over.

  #shot("image14.png", width: 5.8in)

  *Note:* Prescreeners you add are downloadable through Prolific's demographic data export (explained later). Click *Add screeners* to choose from many preset questions and to filter out participants who choose certain answers (or select them all). This is Prolific's recommended way of collecting demographic data. Prolific also recommends validating the prescreener questions at the beginning of your study. If a participant answers inconsistently with their prescreener answer, do not reject them; ask them to return their submission. To do this, word the questions in your study exactly as they are worded in the prescreener.

+ Make sure the rest of the fields match what you want for the study (see _Running Group Studies_ below for the settings that matter most for multiplayer games). Use *preview* to check that everything looks right, then *publish* and confirm the final checks. Once the study is published, participants can start joining.

This concludes the Prolific setup.

== Completion Paths Set Up

When participants finish your study, they return to Prolific with a completion code showing they completed it. Prolific offers three options: redirect them to the completion URL (recommended; it looks like `https://app.prolific.com/submissions/complete?cc=...`), have them copy and paste the code, or neither (submissions then show as NOCODE). A completion path can specify different conditions under which they exited the game, and each path can trigger an automatic action on Prolific (approve, or manual review, with bonuses paid separately). For example, here is a completion path from the revolution game:

#shot("image15.png", width: 6.4in)

Define a code for each way a participant can leave your study (finishing, failing a check, timing out, not enough players, and so on). Breadboard records which code a player exited with, so the data can be matched to participants on Prolific later, and different codes can lead to different pay. Appendix A lists the revolution game's codes and how they map to pay.

= Pre-Launch Checklist

Go through this before you publish on Prolific.

*Breadboard*

- #cb Instance name matches the internal study name you will use on Prolific.
- #cb `DEV` and `SANDBOX` are *false* in Globals (if your study has them).
- #cb Parameters and treatments are set, saved, and the script engine is reloaded.
- #cb The instance is running, and the log terminal is open.
- #cb You have tested the study with AI players or the testing dialog.

*Prolific*

- #cb The study URL's experiment and instance numbers match the Breadboard client URL, and the URL parameters option is selected.
- #cb Exclusion screeners for earlier instances of the study are in place.
- #cb Every completion code in the Breadboard script is entered as a completion path on Prolific, with the same code.
- #cb The time estimate and pay include expected waiting time, and any concurrency limit is set.
- #cb You have looked at *preview*, and your wallet covers rewards plus the platform fee.
- #cb You know when you will pause the study so that nobody joins after the game starts.

#pagebreak()

= Running the Experiment

When running the experiment, there are three primary screens to monitor: Prolific, the Breadboard console, and the terminal logs.

== Session Timeline

A typical live session runs in this order:

+ Check the pre-launch checklist, then publish the study on Prolific.
+ Watch participants arrive in the Breadboard console and the logs.
+ Once there are enough players, pause the study on Prolific so that no one joins after the game starts.
+ Let the game run, watching for idle or stuck players.
+ When the game ends, stop the study on Prolific and download the Breadboard data.
+ Approve the submissions on Prolific, then pay the bonuses.

Approve promptly: Prolific approves submissions that haven't been reviewed within 21 days.

== Terminal Logs

In the terminal, you can see in real time when participants join, the actions they take, and other data.

== Breadboard Console

+ In the console, you can see the nodes representing each player and the choices they select each round. This is shown visually in the *Graph* dialog. To view a specific player, click the *Players* dialog at the bottom. You can filter the player data, as below, to see how many players are at a certain stage in the game (you can also filter by other parameters).

  #shot("image16.png", width: 4.1in)

  _Specific to the revolution game:_ to remove a player, run the `kickPlayers("Player ID")` function in the script dialog.

+ Once the experiment is done, download the data and logs by clicking the download button next to your experiment instance.

  #shot("image17.png", width: 1.2in)

+ The experiment data is a CSV file where each line is an *event*. Events and their data are grouped together by *id*. The ids do not necessarily increase in numerical order, so to order events chronologically, sort by *event_date* instead.

  #shot("image18.png", width: 4.6in)

== Matching Players to Prolific Participants

The study URL passes `PROLIFIC_PID` (the participant ID), `STUDY_ID` and `SESSION_ID` to Breadboard. To pay bonuses or look into a problem, you need to get from a Breadboard player to a Prolific submission:

+ In the Breadboard CSV, find the player's events and the completion code they exited with.
+ Take the player ID from the CSV and look it up in Prolific's *Download demographic data* file, which lists participant IDs alongside submission IDs.
+ Use the submission ID for bonuses and approvals.

Before a real run, join as one test participant and confirm that the player ID in the Breadboard data is the Prolific participant ID. If your study records a different value, match on that value instead.

== Prolific

+ On Prolific, you can see the number of participants, their IDs, and other data such as time taken and completion codes. Once you have enough participants, pause the study with *Action > Pause* at the top right. Pausing does not affect participants who are already in the study. Use *Action > Stop* when the study is complete; stopping is final, though you can duplicate the study.

+ When the study is complete, go through the submissions that still need approval and approve them. To approve them all, select all and click *Approve selected* at the bottom left. Submissions that are not reviewed within 21 days are approved automatically.

+ Once participants are approved, you can pay the bonuses. Click *Bulk actions* at the top right, then *Bulk bonus payment*.

  #shot("image19.png", width: 1.6in)

  Prolific asks for the bonus payments in the format `Submission ID,bonus amount`, one participant per line. It must be Prolific's *submission* ID, not the participant ID; using participant IDs results in failed payments. Submission IDs are at the beginning of the file from *Download demographic data* on the submissions page, next to the participant IDs, so match your player IDs to submission IDs there before pasting.

  #shot("image20.png", width: 4.1in)

  `bulk_bonus.py` (Appendix B) produces this file from the Breadboard event CSV for the revolution game. For another study, adapt it to your study's events.

+ Click *Pay Bonuses*. The update may take a moment; do not submit the same payment again unless Prolific reports that it failed. Bonuses carry Prolific's platform fee (plus VAT if applicable) and cannot be refunded, so the amount charged exceeds the total bonus the script prints.

+ Messages from participants appear in the *Messages* tab on Prolific, but only for the person who published the study, unless your workspace has enabled shared workspace messaging.

= Running Group Studies

Prolific supplies participants but does not match them into groups; matching happens in Breadboard. These Prolific rules matter most for multiplayer games:

- *Waiting time.* Include the expected waiting time in your time estimate and pay.
- *Unmatched participants.* Anyone who waits but is never matched must receive partial pay of at least £0.10 / \$0.14 per minute, and cannot be rejected. In the revolution game, the NOT_ENOUGH_PLAYERS code pays the base pay plus lottery bonus for this reason.
- *First-come, first-served.* Places fill in order of arrival, so a full group is not guaranteed.
- *Concurrency limit.* Under _Limiting simultaneous participant access_ in the Data collection step, select *Limit participant access* and enter the maximum number of simultaneous participants. It is not offered for studies hosted on SurveyMonkey, Qualtrics, Google Forms, Alchemer, Typeform or Gorilla.
- *Conditions.* To assign conditions at the same time, run one Prolific study and randomize in Breadboard rather than running a separate study per condition.
- *Rejections.* Rejections are made one at a time and each needs a reason. Being slow or being screened out is not a valid reason, and Prolific sets a default rejection limit per study.
- *Pay.* Prolific sets a minimum hourly rate and recommends a higher one. You can raise a study's reward after launch but never lower it.

#pagebreak()

= Troubleshooting

*Participants cannot connect.* Check that the instance is running in the console (the status column may still read STOPPED while it runs), reload the script engine, and refresh the page. Check that the experiment and instance numbers in the Prolific URL match the Breadboard client URL.

*Players are stuck before the game.* Check how many players are ready: the game does not start without the minimum number (15 in the revolution game), and the players who wait are dropped with the NOT_ENOUGH_PLAYERS code. For a test with `DEV` set to true, use *Start Init Step* to move players from the ready step to the game.

*Players join after the game has started.* Pause the Prolific study before the game starts. Late arrivals leave with the GAME_STARTED code and are not paid.

*A player is idle or must be removed.* In the revolution game, run `kickPlayers("Player ID")` in the script dialog. Check the exit code in the downloaded data.

*Submissions show NOCODE on Prolific.* The participant did not return through the completion URL or enter a code. Match them to Breadboard by participant ID and check which exit code they received.

*Bonus payments fail on Prolific.* The most likely cause is participant IDs in the list instead of submission IDs. Check the first column of the list, and do not resubmit a payment unless Prolific says it failed.

*A participant messages you.* Messages appear in the *Messages* tab for the person who published the study. If you were not that person, ask them to check.


= Testing Experiments on Breadboard

To test your Breadboard experiment before running it on Prolific, you have two options.

== Testing with AI

Use the following command in the script dialog:

#hl[`g.addAI(a, n, [behavior])`]

Then define your own behavior for the vertices. Here is an example from the Breadboard documentation website:

```groovy
def aiBehavior = { ai->
  // Sanity check to make sure the AI actually has choices to make
  if (ai.getProperty("choices")) {
    // A random delay is a good idea to make the AI
    // appear more human and to avoid potential race conditions
    def randomDelay = 1000 + r.nextInt(3000)
    new Timer().runAfter(randomDelay) {
      def choices = ai.getProperty("choices")
      // Choose a random choice
      def choice = choices[r.nextInt(choices.size())]
      a.choose(choice.uid)
    }
  }
}

// Add 20 AI players using the defined behavior
g.addAI(a, 20, aiBehavior)
```

== Testing with Breadboard's Testing Dialog

You can also create multiple vertices and go through the experiment from the participant's perspective, using these two commands in the script dialog:

#hl[`g.addVertices(5)`]

#hl[`g.V.each{ it.testmode = true }`]

The first statement adds five vertices (participants) to the graph. The second puts all of them into test mode. Once you execute these commands, open the testing dialog to see the participants' screens:

#shot("image21.png", width: 6.5in)

The screens are small, but you can zoom in with Cmd/Ctrl and +. Alternatively, click the client URL next to the experiment instance and log in with a different participant ID (anything, as long as each is different) *on different tabs*. This lets you navigate the participant screens in a larger view than the Breadboard testing dialog.

For some games, if there is a `DEV` variable in the Globals step, you can set it to true and click the "Start Init Step" button in Breadboard to move players from the ready step into the game.

= Data Handling

The Breadboard CSV and Prolific exports link participant IDs to behavior and to pay.

- Store them in the project's data folder, not in email or shared chats.
- Keep the participant-ID-to-submission-ID file separate from the files you analyze, and remove participant IDs from analysis copies.
- The bonus files (`bulk_bonus_payment.csv` and `metadata_bonus.csv`) contain participant or submission IDs and amounts. Delete them once the payments are confirmed.
- Prescreener answers in the Prolific export are demographic data; handle them as you would the rest of the study data.


= Conclusion

That concludes the guide for running Breadboard experiments on Prolific. Happy experimenting!


#pagebreak()

#heading(numbering: none)[Appendix A: Revolution Game Completion Codes]

These are the codes from one revolution game study, as an example. Prolific generates a new set of codes for each study, so enter your own codes in the Breadboard script and on Prolific. The revolution game has two possible bonus payments: one from the lottery round and one from the revolution game itself. It requires at least 15 players to proceed; players dropped for lack of players leave with the NOT_ENOUGH_PLAYERS code (C1MCVOIC in the completion path shown earlier). Players are paid different bonuses depending on their code.

#show figure: set block(breakable: true)
#figure(
  table(
    columns: (2.0in, 1.0in, 1fr, 1.0in),
    inset: 5pt,
    stroke: 0.5pt + luma(180),
    align: (left, left, left, left),
    table.header([*Completion Code Name*], [*Prolific Code*], [*Description*], [*Bonus*]),
    [#hl[COMPLETE]], [C1MTZON7], [Players who completed all rounds of the experiment successfully], [Base pay + both bonuses],
    [#hl[FAILED_LOTTERY]], [C1HY3M7Y], [Players who demonstrated irrational behavior in the lottery. Irrational behavior is defined as picking the option that has a 0% chance of payment in the first or last lottery choice, or when the number of swaps between the choices exceeds 3.], [Base pay + lottery bonus],
    [#hl[FAILED_QUIZ]], [CLYTL771], [Players who failed the comprehension quiz at the end of the tutorial (missed more than two questions after two attempts).], [Base pay + lottery bonus],
    [#hl[PLAYER_IDLE]], [C8NGXRRJ], [Players who were idle for too long during the game (i.e. didn't make a choice within the allotted time).], [Base pay + lottery bonus],
    [#hl[NOT_READY]], [CTQFLWV0], [Players who did not click the ready button within the allotted time after the 20-minute timer for the tutorial ended.], [Base pay + lottery bonus],
    [#hl[DIDN'T_COMPLETE\_#sym.zws;TUTORIAL]], [CO0HI6W4], [Players who did not complete the tutorial within 20 minutes.], [Unpaid],
    [#hl[NOT_ENOUGH_PLAYERS]], [C1MCVOIC], [If the number of ready players is not at least 15 by the time the game is supposed to start, all the ready players are dropped with this code.], [Base pay + lottery bonus],
    [#hl[TOO_MANY_PLAYERS]], [C7HOJMLQ], [If the number of ready players exceeds 25 by the time the game is supposed to start, random players are dropped with this code to bring the number down to 25.], [Base pay + lottery bonus],
    [#hl[FAILED_CAPTCHA]], [C18LDTAB], [Players who fail the captcha], [Unpaid],
    [#hl[GAME_STARTED]], [CQ4P9QVU], [Players who join when the game has already started (should not happen if the Prolific study is paused before the game starts).], [Unpaid],
  ),
)


#heading(numbering: none)[Appendix B: Revolution Game Bonus Script]

`bulk_bonus.py` turns the Breadboard event CSV (downloaded in step 2 of _Breadboard Console_) into the `submission ID,amount` list that Prolific's bulk bonus tool takes. It reads the `player`, `bonus` (in cents) and `exitType` values of each `removedPlayer` event.

```sh
python bulk_bonus.py EVENTS.csv --prolific-export PROLIFIC.csv
```

- `EVENTS.csv` is the Breadboard download. `PROLIFIC.csv` is Prolific's *Download demographic data* file. With it, the script swaps each player's participant ID for the matching submission ID, and writes nothing if any paid player has no match. Without it, the script warns that the output uses Breadboard player IDs.
- It writes `bulk_bonus_payment.csv` (paste into Prolific) and `metadata_bonus.csv` (IDs, amounts and exit types, for reference).
- It prints the number of players, the number of payments and the total bonus. Compare these with Prolific before you pay.
- A player removed more than once is paid once, for the earliest removal.

#raw(read("bulk_bonus.py"), lang: "python", block: true)
