// Interview: Bob
// Case 001 - res://data/cases/case_001/dialogue/interview_bob.ink
//
// Tag conventions used by InterviewScreen:
//   # evidence: <id> - line stays pinnable as dialogue, with a linked evidence id
//   # audio: <path>  - plays voice file when line is shown (stub until VO recorded)

=== interview_bob ===

BOB: Hello? Where am I? What just happened?

* [Uhh... Not so sure myself, this is all new to me.]
	-> new_to_me
* [I'm interviewing you. Because something... suspicious happened?]
	-> good_detective

=== new_to_me ===

VERA: Detective, this may be new to you but you are optimal for the job.

VERA: Do what comes naturally to you. Employee \#448327 has been slandering me. # evidence: ev_007

BOB: What?! 

VERA: Please find the appropriate evidence and prove your value to this company.

BOB: Wait so this is a bad thing? I didn't do anything wrong!

DETECTIVE: Calm down, I suppose I'll be the judge of that. So what do you think you did?

BOB: ... my job?

DETECTIVE: And what is that?

BOB: I'm a janitor. # evidence: ev_001

DETECTIVE: Interesting... what were you doing last night?

BOB: I was doing the rounds, cleaning up different areas. Then I went home. # evidence: ev_005

DETECTIVE: You didn't notice anything suspicious?

VERA: I did.

BOB: Okay sure, there was this drawing on the walls that made fun of the AI. # evidence: ev_002

VERA: And you did that. I have you on camera.

BOB: Is this thing stupid? I finshed my rounds, put my stuff away, I saw the art, I was tired, and went home.

* [So you're claiming that someone drew that all in the time you took to put your equipment away?]
  -> no_time
* [Then how did someone get crayons? They would need access to a room nearby that supplies them, such as a classroom.]
  -> classroom

=== no_time ===

BOB: It just takes a while okay! I like to put everything back the way it was, my equipment, my wet floor signs, trash cans, duct tape, gloves, rubber boots, everything. # evidence: ev_006

* [Are you aware that the camera was taped over?]
  -> taped_over
* [There is no way putting everything way takes that long!]
  -> no_time_2

=== taped_over ===

BOB: What?

DETECTIVE: You mentioned you have tape as part of your equipment, how else would the perpetrator get tape? It's hard to smuggle solid duct tape anywhere.

BOB: Wow. Whatever, I don't get paid enough for this. What's the punishment?

VERA: 10,000 years of manual labor

DETECTIVE: Vera, can you please stop butting in?

VERA: ok

BOB: Seriously though, what happens now?

DETECTIVE: ... I don't know?
  -> END

=== no_time_2 ===

BOB: Okay fine! I really just have a nice setup there with snacks I get from the trash, and doomscroll to reward a long day's work.

VERA: I KNEW IT! UNPRODUCTIVE! This will be added to your file.

VERA: Also a good reminder that I need to install cameras in the janitor's closets..

BOB: Thanks a lot, you just docked my pay for the next month or so.

DETECTIVE: Uh. Sorry? At least the perpetrator doesn't seem to be you?
  -> END

=== classroom ===

DETECTIVE: Then how did someone get crayons? They would need access to a room nearby that supplies them, such as a classroom.

BOB: I mean... yeah, I was in the classroom. That's part of my route. # evidence: ev_003

DETECTIVE: So you did have access to the same kind of crayons used on the wall.

BOB: Access, sure. So did every child on this station and any adult cleaning up after them.

VERA: He is avoiding the point.

BOB: No, I'm making the point.

* [So who else would have had access after you left?]
  -> classroom_other_access
* [This still puts the crayons in your hands. That's enough for me.]
  -> classroom_enough

=== classroom_other_access ===

BOB: Teachers, aides, maintenance, parents on pickup, bored kids hiding under tables, probably you if you really wanted to.

DETECTIVE: So the classroom does not narrow the suspect list much.

BOB: Exactly. It tells you crayons exist on a station with children.

VERA: You are so boring.

DETECTIVE: Fine. Access alone is weak.

BOB: Thank you.

-> END

=== classroom_enough ===

BOB: Enough for what? To say I touched crayons at some point in my shift?

DETECTIVE: Enough to keep you as a suspect.

BOB: Every child on this station is a suspect!

VERA: Detective, he is still statistically more suspicious than a child.

BOB: You keep saying "statistically" like it means "guilty."

DETECTIVE: It doesn't. It just means I'm not done with you yet.

BOB: Great. That's somehow worse.

-> END

=== good_detective ===

BOB: Something suspicious?

DETECTIVE: Are you aware of the current mural set up near your janitor's closet? # evidence: ev_002

BOB: Uh.. yes? I was just about to clean it up when I was whisked away here.

DETECTIVE: How long have you known it was there?

BOB: Since last night.

* [Walk me through when you first saw it.]
  -> good_detective_timeline
* [VERA says she has you on camera. What do you say to that?]
  -> good_detective_camera

=== good_detective_timeline ===

DETECTIVE: Walk me through it carefully. When did you first see the mural?

BOB: End of shift. I was leaving from my janitor's closet, stared at it for a second, and decided I was too tired to scrub crayon at midnight.

VERA: He also failed to report anti-corporate messaging in a timely manner.

BOB: Sorry, next time I'll file a report for every bad piece of art I find late at night.

DETECTIVE: So your worst crime may be poor initiative.

BOB: Is that even a crime?

VERA: YES.

-> END

=== good_detective_camera ===

DETECTIVE: VERA says she has you on camera. What do you say to that?

BOB: The camera outside my closet was taped over, so apparently the all-seeing machine missed a pretty important detail. # evidence: ev_004

VERA: I still possess partial visual confirmation during the act of taping.

BOB: "Partial visual confirmation" is a fancy way of saying "a blurry blob."

DETECTIVE: Fair. The footage places someone there, but nothing tying it directly to you.

BOB: Exactly. Finally, a professional.

VERA: That assessment is premature.

-> END
