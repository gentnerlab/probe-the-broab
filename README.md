spike2_scripts
==============

scripts used for experiment control


## prepping the directories
1.	Create subject folder in top level data directory (e.g. `F:/Experiments/raw/`)
1.	Create subfolders, “data” and “stims”
1.	Place desired .wav files (at 40kHz) in “stims” folder
1.	Copy the contents of `probe-the-broab\protocolfiles\` into `{subject folder}\stims\`

## launching the script
1.	Open Spike2 version 8 
1.	Run the script `probe-the-broab\ChronicScript.s2s`
1.	Follow the prompts
	-  if window “warning all pre trigger data might not be saved” pops up, hit “ok” (It would be better to track down why this is happening, but for now there doesn’t seem to be any data loss, so I’m ignoring it…)
1.	Set subject folder. Browse until you highlight the subject folder you created in step 1, and hit ‘ok’
1.	Specify Behavioral Protocol - this only appears the first time running the script for a given bird - unless the bird was explicitly trained on GNG pick “2AC”, since it’s slightly less likely things will break

## neural recording
1.	click on ‘start epoch’ in the toolbar
1.	Use Protocol File? “yep”
1.	Pick Protocol File to Use 
	1.	Select “NO_Search_AskStimFile_prot.txt” to loop through the stimuli in order
	1.	Select “NO_Block_AskStimFile_prot.txt” to run a block
1.	New Penetration/Use Current Penetration? set the value of the current penetration (electrode, hemisphere, AP distance, ML distance)
1.	Use Current Recording Site? set the value of the current site (depth)
1.	Use stim File?  NO - click the LEFT button (it will now think for a little while)
1.	Which Channels to Record? Ch36 is the stim channel
1.	Epoch Comments any comments you want recorded

It should now be recording!

### block protocol
1.	Select Block Stims - if you selected the Block protocol file, set up the block
1.	Buttons present during recording (right to left):
	-	Finish Experiment - finishes whole experiment - probably want to use ‘stop recording epoch’ instead
	-	Pause Block <DOESN’T WORK - IGNORE>
	-	Loop this Search Stim - loops current stimulus indefinitely - click again when called ‘all search stims’ to go back to everything
	-	Stop Recording Epoch - stops the current recording setup, without exiting setup for current bird/experiment
	-	Adjust Gains <DOESN’T WORK - IGNORE>
	-	Start Epoch
	-	SelectActiveStims - lets you select a subset of stimuli to present
	-	Close Behavior Checks  <DOESN’T WORK - IGNORE>
	-	Behavior Summary  <DOESN’T WORK - IGNORE>
	-	Cancel all CARs - deletes virtual channels set up by ‘Setup CAR’
	-	Setup CAR
		1.	Highlight all channels you want to use as references, then click the button
		2.	select the channel you want to subtract the selected channels from
	-	Setup Software Referencing <DOESN’T WORK - IGNORE>
	-	Load Last View - if you had a previously recorded Epoch in the current script instance, you can apply it to the current recording by clicking this button
1.	Press Stop Recording Epoch or Finish Experiment to finish the current recording.
1.	Data is saved into `{subject folder}/data/Pen()/Site()/Epc()`


# protocol variables

* "protocolmode" (required)
	* "neuronly": only neural recording (no behavior)
	* "behavonly": only behavior (no neural recording)
	* "neurbehav": neural recording and behavior
* "protocolstimselectionstyle" (required)
	* "search": loops through stimuli. displays toggle during stimulus presentation to loop a stimulus.
	* "block": shuffles a stimulus set. terminates when block is complete.
	* "random": randomly samples from stimulus set.
* "micport"
* "peckstopon"
* "correctiontrialson"
* "dofeedcorrectiontrials"
* "trialsavailablecycleonminutes"
* "trialsavailablecycleoffminutes"
* "despctpres"
* "despctreinf"
* "despctto"
* "variableratiomax"
* "respwin"
* "feed"
* "timeout"
* "iti"
* "itino"
* "maxitino"
* "minitino"
* "stimfilename"
* "dosavemicchannel"
* "beginhours"
* "beginmins"
* "endhours"
* "endmins"
* "dontusetodstartstop"

# DigMarks

### Stimulus
* `<` (60): start of stimulus
* `>` (62): end of stimulus

### Response
* `R` (82): right key peck
* `C` (67): center key peck
* `L` (76): left key peck

### Consequence
* `F` (70): Correct. Feed start
* `f` (102): Correct. No feed
* `}` (125): End of feed period
* `T` (84): Incorrect. Start timeout
* `t` (116): Incorrect. No timeout
* `]` (93): End of timeout period
* `N` (78): No Response

### Trial logic
* `(` (40): Start of intertrial interval
* `)` (41): End of intertrial interval


