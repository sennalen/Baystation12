

/datum/markov
	var/list/vocabulary = list()
	var/vocabulary_lookup = list()
	var/degree = 2
	var/weighted = TRUE
	var/list/no_preceding_space = list(".", "?", "!", ",", ")", ";", ":", "-")
	var/list/no_following_space = list("(", "-")
	var/list/terminators = list(".", "!", "?", ";")
	var/list/connectors = list(",", "-", ":", "and", "but")
	var/list/intros = list("with", "on", "from", "anti", "super", "either", "is", "I", "say", "says")
	var/list/filter = list(";", "(", ")", "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
	var/list/replace = list("%"="percent", "&"="and")
	var/transitions = list()
	var/priorities = list()

/datum/markov/proc/key_to_string(key)
	var/result = ""
	var/start = 1 + length(key) - degree + (length(key) > degree)? 1 : 0
	for(var/i in start to degree)
		result += ":[key[i]]"
	return result

/datum/markov/proc/import_corpus(text)
	var/words_initial = splittext(text, regex("\\s+|(\[\\.!?,-;\\(\\)])"))
	var/words = list()

	for(var/w in words_initial)
		w = lowertext(trim(w))
		w = replace[w] || w
		if(!length(w))
			continue
		words += w
		if(!(w in vocabulary))
			vocabulary += w
			vocabulary_lookup[w] = length(vocabulary)

	for(var/i = 1 to length(words))

		var/wi = lowertext(words[i])
		if ((!wi) || !length(wi) || (wi in filter))
			continue

		var/list/key = list()

		for(var/j = degree to 1 step -1)
			var/k = i-j
			if(k >= 1)
				var/wk = lowertext(trim(words[k]))
				if(wk in terminators)
					var/n = length(key)
					key = list()
					while(length(key) < n+1)
						key += -1
				else
					key += vocabulary_lookup[wk]
			else
				key += -1


		var/keystring = key_to_string(key)

		if(!(keystring in transitions))
			transitions[keystring] = list()
		if(!(wi in transitions[keystring]))
			transitions[keystring][wi] = 0

		transitions[keystring][wi] += 1


/datum/markov/proc/choose_word(state, prioritize=null, can_guess=FALSE)
	var/keystring = key_to_string(state)
	var/choices = transitions[keystring]
	if(choices && length(choices))
		if(prioritize)
			for(var/x in prioritize)
				if(x in choices)
					return x

		var/c = null
		if(weighted)
			c = pickweight(choices)
		else
			c = pick(choices)

		if (can_guess)
			if(!c || (!length(c)) || (c in terminators))
				c = pick(choices)

		return c


/datum/markov/proc/generate_text(prefix, max_words = 30, stop_on_terminator = TRUE)
	var/list/state = list()
	while(length(state) < degree)
		state += -1

	var/output = ""
	var/num_words_generated = 0
	var/last_word = null
	var/retries = 0

	var/list/guaranteed = null
	if(prefix && length(prefix))
		guaranteed = splittext(prefix, regex("\\s+|(\[\\.!?,-;\\(\\)])"))

	for(var/failsafe in 1 to 2*max_words)
		if(failsafe > max_words)
			log_world("failsafe [failsafe]")

		if((num_words_generated >= max_words) && !(last_word in connectors))
			break

		var/next_word = null
		log_world("a [retries]")

		if(istype(guaranteed) && length(guaranteed))
			next_word = lowertext(trim(guaranteed[1]))
			log_world("b [next_word]")
			guaranteed.Cut(1,2)
			if(!length(next_word))
				continue

		else
			next_word = choose_word(state, priorities, FALSE)
			var/retry = FALSE
			log_world("c [next_word] [key_to_string(state)]")
			if(!next_word)
				if((last_word in terminators))
					break
				else if((last_word in connectors) || (last_word in intros))
					next_word = pick(vocabulary)
				else if(prob(90))
					next_word = "."
				else
					next_word = ","
			log_world("d [next_word] [retry]")

			if((next_word in terminators) || (next_word in connectors))
				if (num_words_generated == 0)
					retry = TRUE
				if ((last_word in terminators) || (last_word in connectors))
					retry = TRUE
				if (last_word in intros)
					retry = TRUE
			log_world("e [next_word] [retry]")

			if(next_word == last_word)
				retry = TRUE
			log_world("f [next_word] [retry]")

			if(next_word in list(";", "(", ")"))
				log_world("bad char [next_word]")
				retry = TRUE
			log_world("g [next_word] [retry]")

			if(length(trim(next_word)) == 0)
				log_world("empty word [next_word]")
				retry = TRUE
			log_world("h [next_word] [retry]")

			if (retry)
				if (retries > 3)
					next_word = pick(vocabulary)
				else
					continue

			retries = 0

		priorities -= next_word

		log_world("i [next_word]")

		state.Cut(1,2)
		state += vocabulary_lookup[next_word] || -1

		var/space = ((next_word in no_preceding_space) || (last_word in no_following_space)) ? "" : " "
		if((num_words_generated == 0) || (last_word in terminators) || (next_word == "i"))
			next_word = capitalize(next_word)
		output += "[space][next_word]"

		if (stop_on_terminator && (next_word in terminators))
			break

		num_words_generated += 1
		last_word = next_word



	return output


/datum/chatbot
	var/corpus = ""
	var/datum/markov/generator = null
	var/degree = 2
	var/priorities = list()
	var/topics = list()
	var/watch = list()

/datum/chatbot/New()
	generator = new
	generator.degree = degree
	generator.import_corpus(corpus)

/datum/chatbot/proc/speak()
	return generator.generate_text()

/datum/chatbot/proc/react_to(message)
	var/prefix = null
	var/words = splittext(message, regex("\\s+|(\[\\.!?,-;\\(\\)])"))
	for(var/w in words)
		w = lowertext(trim(w))
		if(w in watch)
			var/topic = watch[w]
			log_world("[w] topic [topic]")
			prefix = pick(topics[topic])
			break
		if(w in generator.vocabulary)
			generator.priorities += w
	return generator.generate_text(prefix)



/datum/ai_holder/simple_animal/retaliate/chatty
	var/datum/chatbot/chatholder = new /datum/chatbot/medical()
	speak_chance = 2

/datum/ai_holder/simple_animal/retaliate/chatty/on_hear_say(mob/living/speaker, message, language, sound_volume)
	if(istype(holder) && istype(speaker))
		if(speaker != holder)
			var/text = chatholder.react_to(message)
			delayed_say(text, speaker)
			if(prob(50))
				speak_chance = 10

/datum/ai_holder/simple_animal/retaliate/chatty/handle_idle_speaking()
	if (prob(speak_chance))
		var/text = chatholder.speak()
		holder.ISay(text)
	speak_chance = 2

/mob/living/simple_animal/hostile/retaliate/goose/doctor/chatty
	ai_holder = /datum/ai_holder/simple_animal/retaliate/chatty
	languages = list(LANGUAGE_HUMAN_EURO)


/datum/chatbot/flatland
	corpus = {"I call our world Flatland, not because we call it so, but to make its nature clearer to you, my happy readers, who are privileged to live in Space. Imagine a vast sheet of paper on which straight Lines, Triangles, Squares, Pentagons, Hexagons, and other figures, instead of remaining fixed in their places, move freely about, on or in the surface, but without the power of rising above or sinking below it, very much like shadows only hard with luminous edges and you will then have a pretty correct notion of my country and countrymen. Alas, a few years ago, I should have said 'my universe' but now my mind has been opened to higher views of things.
In such a country, you will perceive at once that it is impossible that there should be anything of what you call a 'solid' kind; but I dare say you will suppose that we could at least distinguish by sight the Triangles, Squares, and other figures, moving about as I have described them. On the contrary, we could see nothing of the kind, not at least so as to distinguish one figure from another. Nothing was visible, nor could be visible, to us, except Straight Lines; and the necessity of this I will speedily demonstrate.
Place a penny on the middle of one of your tables in Space; and leaning over it, look down upon it. It will appear a circle.
But now, drawing back to the edge of the table, gradually lower your eye (thus bringing yourself more and more into the condition of the inhabitants of Flatland), and you will find the penny becoming more and more oval to your view, and at last when you have placed your eye exactly on the edge of the table (so that you are, as it were, actually a Flatlander) the penny will then have ceased to appear oval at all, and will have become, so far as you can see, a straight line.
The same thing would happen if you were to treat in the same way a Triangle, or a Square, or any other figure cut out from pasteboard. As soon as you look at it with your eye on the edge of the table, you will find that it ceases to appear to you as a figure, and that it becomes in appearance a straight line. Take for example an equilateral Triangle who represents with us a Tradesman of the respectable class. Figure 1 represents the Tradesman as you would see him while you were bending over him from above; figures 2 and 3 represent the Tradesman, as you would see him if your eye were close to the level, or all but on the level of the table; and if your eye were quite on the level of the table (and that is how we see him in Flatland) you would see nothing but a straight line.
When I was in Spaceland I heard that your sailors have very similar experiences while they traverse your seas and discern some distant island or coast lying on the horizon. The far-off land may have bays, forelands, angles in and out to any number and extent; yet at a distance you see none of these (unless indeed your sun shines bright upon them revealing the projections and retirements by means of light and shade), nothing but a grey unbroken line upon the water.
Well, that is just what we see when one of our triangular or other acquaintances comes towards us in Flatland. As there is neither sun with us, nor any light of such a kind as to make shadows, we have none of the helps to the sight that you have in Spaceland. If our friend comes closer to us we see his line becomes larger; if he leaves us it becomes smaller; but still he looks like a straight line; be he a Triangle, Square, Pentagon, Hexagon, Circle, what you will; a straight Line he looks and nothing else.
You may perhaps ask how under these disadvantagous circumstances we are able to distinguish our friends from one another, but the answer to this very natural question will be more fitly and easily given when I come to describe the inhabitants of Flatland. For the present let me defer this subject, and say a word or two about the climate and houses in our country.
As to the doctrine of the Circles it may briefly be summed up in a single maxim, 'Attend to your Configuration.' Whether political, ecclesiastical, or moral, all their teaching has for its object the improvement of individual and collective Configuration with special reference of course to the Configuration of the Circles, to which all other objects are subordinated.
It is the merit of the Circles that they have effectually suppressed those ancient heresies which led men to waste energy and sympathy in the vain belief that conduct depends upon will, effort, training, encouragement, praise, or anything else but Configuration. It was Pantocyclus the illustrious Circle mentioned above, as the queller of the Colour Revolt who first convinced mankind that Configuration makes the man; that if, for example, you are born an Isosceles with two uneven sides, you will assuredly go wrong unless you have them made even for which purpose you must go to the Isosceles Hospital; similarly, if you are a Triangle, or Square, or even a Polygon, born with any Irregularity, you must be taken to one of the Regular Hospitals to have your disease cured; otherwise you will end your days in the State Prison or by the angle of the State Executioner.
All faults or defects, from the slightest misconduct to the most flagitious crime, Pantocyclus attributed to some deviation from perfect Regularity in the bodily figure, caused perhaps (if not congenital) by some collision in a crowd; by neglect to take exercise, or by taking too much of it; or even by a sudden change of temperature, resulting in a shrinkage or expansion in some too susceptible part of the frame. Therefore, concluded that illustrious Philosopher, neither good conduct nor bad conduct is a fit subject, in any sober estimation, for either praise or blame. For why should you praise, for example, the integrity of a Square who faithfully defends the interests of his client, when you ought in reality rather to admire the exact precision of his right angles? Or again, why blame a lying, thievish Isosceles, when you ought rather to deplore the incurable inequality of his sides?
Theoretically, this doctrine is unquestionable; but it has practical drawbacks. In dealing with an Isosceles, if a rascal pleads that he cannot help stealing because of his unevenness, you reply that for that very reason, because he cannot help being a nuisance to his neighbours, you, the Magistrate, cannot help sentencing him to be consumed and there's an end of the matter. But in little domestic difficulties, when the penalty of consumption, or death, is out of the question, this theory of Configuration sometimes comes in awkwardly; and I must confess that occasionally when one of my own Hexagonal Grandsons pleads as an excuse for his disobedience that a sudden change of temperature has been too much for his Perimeter, and that I ought to lay the blame not on him but on his Configuration, which can only be strengthened by abundance of the choicest sweetmeats, I neither see my way logically to reject, nor practically to accept, his conclusions.
For my own part, I find it best to assume that a good sound scolding or castigation has some latent and strengthening influence on my Grandson's Configuration; though I own that I have no grounds for thinking so. At all events I am not alone in my way of extricating myself from this dilemma; for I find that many of the highest Circles, sitting as Judges in law courts, use praise and blame towards Regular and Irregular Figures; and in their homes I know by experience that, when scolding their children, they speak about 'right' and 'wrong' as vehemently and passionately as if they believe that these names represented real existence, and that a human Figure is really capable of choosing between them.
Constantly carrying out their policy of making Configuration the leading idea in every mind, the Circles reverse the nature of that Commandment which in Spaceland regulates the relations between parents and children. With you, children are taught to honour their parents; with us next to the Circles, who are the chief object of universal homage a man is taught to honour his Grandson, if he has one; or, if not, his Son. By 'honour,' however, is by no means mean 'indulgence,' but a reverent regard for their highest interests: and the Circles teach that the duty of fathers is to subordinate their own interests to those of posterity, thereby advancing the welfare of the whole State as well as that of their own immediate descendants.
The weak point in the system of the Circles if a humble Square may venture to speak of anything Circular as containing any element of weakness appears to me to be found in their relations with Women.
As it is of the utmost importance for Society that Irregular births should be discouraged, it follows that no Woman who has any Irregularities in her ancestry is a fit partner for one who desires that his posterity should rise by regular degrees in the social scale.
Now the Irregularity of a Male is a matter of measurement; but as all Women are straight, and therefore visibly Regular so to speak, one has to devise some other means of ascertaining what I may call their invisible Irregularity, that is to say their potential Irregularities as regards possible offspring. This is effected by carefully-kept pedigrees, which are preserved and supervised by the State; and without a certified pedigree no Woman is allowed to marry.
Now it might have been supposed the a Circle proud of his ancestry and regardful for a posterity which might possibly issue hereafter in a Chief Circle would be more careful than any other to choose a wife who had no blot on her escutcheon. But it is not so. The care in choosing a Regular wife appears to diminish as one rises in the social scale. Nothing would induce an aspiring Isosceles, who has hopes of generating an Equilateral Son, to take a wife who reckoned a single Irregularity among her Ancestors; a Square or Pentagon, who is confident that his family is steadily on the rise, does not inquire above the five-hundredth generation; a Hexagon or Dodecagon is even more careless of the wife's pedigree; but a Circle has been known deliberately to take a wife who has had an Irregular Great-Grandfather, and all because of some slight superiority of lustre, or because of the charms of a low voice which, with us, even more than with you, is thought 'an excellent thing in a Woman.'
Such ill-judged marriages are, as might be expected, barren, if they do not result in positive Irregularity or in diminution of sides; but none of these evils have hitherto provided sufficiently deterrent. The loss of a few sides in a highly-developed Polygon is not easily noticed, and is sometimes compensated by a successful operation in the Neo-Therapeutic Gymnasium, as I have described above; and the Circles are too much disposed to acquiesce in infecundity as a law of the superior development. Yet, if this evil be not arrested, the gradual diminution of the Circular class may soon become more rapid, and the time may not be far distant when, the race being no longer able to produce a Chief Circle, the Constitution of Flatland must fall.
One other word of warning suggest itself to me, though I cannot so easily mention a remedy; and this also refers to our relations with Women. About three hundred years ago, it was decreed by the Chief Circle that, since women are deficient in Reason but abundant in Emotion, they ought no longer to be treated as rational, nor receive any mental education. The consequence was that they were no longer taught to read, nor even to master Arithmetic enough to enable them to count the angles of their husband or children; and hence they sensibly declined during each generation in intellectual power. And this system of female non-education or quietism still prevails.
My fear is that, with the best intentions, this policy has been carried so far as to react injuriously on the Male Sex.
For the consequence is that, as things now are, we Males have to lead a kind of bi-lingual, and I may almost say bimental, existence. With Women, we speak of 'love,' 'duty,' 'right,' 'wrong,' 'pity,' 'hope,' and other irrational and emotional conceptions, which have no existence, and the fiction of which has no object except to control feminine exuberances; but among ourselves, and in our books, we have an entirely different vocabulary and I may also say, idiom. 'Love' them becomes 'the anticipation of benefits'; 'duty' becomes 'necessity' or 'fitness'; and other words are correspondingly transmuted. Moreover, among Women, we use language implying the utmost deference for their Sex; and they fully believe that the Chief Circle Himself is not more devoutly adored by us than they are: but behind their backs they are both regarded and spoken of by all but the very young as being little better than 'mindless organisms.'
Our Theology also in the Women's chambers is entirely different from our Theology elsewhere.
Now my humble fear is that this double training, in language as well as in thought, imposes somewhat too heavy a burden upon the young, especially when, at the age of three years old, they are taken from the maternal care and taught to unlearn the old language except for the purpose of repeating it in the presence of the Mothers and Nurses and to learn the vocabulary and idiom of science. Already methinks I discern a weakness in the grasp of mathematical truth at the present time as compared with the more robust intellect of our ancestors three hundred years ago. I say nothing of the possible danger if a Woman should ever surreptitiously learn to read and convey to her Sex the result of her perusal of a single popular volume; nor of the possibility that the indiscretion or disobedience of some infant Male might reveal to a Mother the secrets of the logical dialect. On the simple ground of the enfeebling of the male intellect, I rest this humble appeal to the highest Authorities to reconsider the regulations of Female education.
"}


/datum/chatbot/medical
	topics = list(
		"hi"=list("Hello,", "Good morning,", "How are you?"),
		"help"=list("Tell me", "Please"),
		"diagnosis"=list("It looks like", "My diagnosis"),
		"prognosis"=list("I think", "Probably,", "The prognosis is"),
		"prescribe"=list("I prescribe", "The patient needs", "I recommend", "Administer", "This requires", "dylovene", "inaprovaline", "bicaridine", "antidexafen", "citalopram") )
		"quack"=list("I graduated top of my class", "My specialty is", "I know what I'm talking about when I say")
	watch = list(
		"hi"="hi", "hello"="hi", "morning"="hi", "afternoon"="hi", "doctor"="hi", "goose"="hi", "dr"="hi", "anatidae"="hi",
		"help"="help", "problem"="help", "emergency"="help", "sick"="help", "injured"="help", "trauma"="help", "shot"="help", "hurt"="help", "hurts"="help", "pain"="help", "feel"="help", "patient"="diagnosis",
		"diagnosis"="diagnosis", "diagnose"="diagnosis", "symptom"="diagnosis", "symptoms"="diagnosis", "breathe"="diagnosis", "breathing"="diagnosis", "heart"="diagnosis", "liver"="diagnosis", "lungs"="diagnosis", "fever"="diagnosis", "vomiting"="diagnosis", "head"="diagnosis", "arm"="diagnosis",
		"prognosis"="prognosis", "surgery"="prognosis", "operating"="prognosis", "okay"="prognosis", "die"="prognosis", "live"="prognosis"
		"prescription"="prescribe", "prescribe"="prescribe", "medicine"="prescribe", "recommend"="prescribe", "recommendation"="prescribe", "should"="prescribe", "treatment"="prescribe", "suggest"="prescribe", "suggestion"="prescribe",
		"qualified"="quack", "unqualified"="quack", "wrong"="quack", "quack"="quack"
	)
	corpus = {"Everything in your body revolves around the brain. So long as your brain isn't dead, you're not dead. Everything else is just there to keep the brain alive, and the severity of any given injury is a direct measure of how much of a threat it poses to the brain.

Certain types of effects can cause your brain's integrity to lower. When it hits 0%, you are braindead - and there's no coming back from that.

The things that pose the biggest threat to your brain on board this ship,

    Lack of oxygen flow.
    Direct physical harm to the brain.
    Toxins in the bloodstream.

Lack of oxygen can be caused by many things - exposure to vacuum, being poisoned with Lexorin, and so on. The most common cause is blood loss.

Alternately, even if you're getting sufficient blood to your brain, and even if it's full of delicious oxygen. Your first line of defense against this is your liver, with your kidneys playing backup, but you'll still need to clear toxins out of your blood, through whatever means, as fast as possible. See Organs and Toxins, below, for more information.

And, finally, somebody shooting you in the brain will obviously not be a good thing for your brain integrity, either. Protect your noggin, or end up as a pink splatter on the walls.

Blood loss, insufficient oxygenation of the blood, and lack of circulation; This is among the most common threats to patients' brains aboard the Torch.

Mechanically, what ultimately matters is your level of blood oxygenation. This is a numerical value, ranging from 0% to 100%, determined by

    Blood volume; Restore blood with IV drips.
    Make sure they have breathable air. Dexalin (Plus) is also very helpful.
    A damaged heart is especially dangerous. Surgery, Cryotubes, and Peridaxon all directly heal organs.


If someone is in cardiac arrest, they are priority number one.

    If you are ever in doubt what to do, put the patient into a stasis bag. You can scan them with your health analyzer and inject them with a syringe even if the bag is closed.
    First, make sure the heart won't stop again. Was it caused by pain? Administer painkillers, then use a defibrillator.
    It could've been caused by low blood volume - hypovolemic shock. Get some blood into them with IV drips and restart the heart with a defibrillator or CPR.
    Was it caused by severe heart damage? You can see this if their blood oxygenation is dangerously low. Put them into a stasis bag or cryo tube, tell the Physician the patient needs instant surgery, then bring them in.
    It could've been caused by a lack of oxygen sending the heart into an abnormal rhythm. Restart the heart with defibrillator or CPR. If they have air, that's it. Otherwise, administer Inaprovaline to stabilize their pulse.
    If the patient is in surgery, or you just can't get a defibrillator, administer CPR.

    Poison in your blood is exceptionally bad news. As long as it's there, it will inflict continuously-stacking damage on your organs, brain included.

Toxins are filtered out by your liver. Once it fails, the kidney is next and your body is without any kind of a protection. All your other organs will shut down.

In case of toxins,

    Use dialysis to remove the toxins.
    Administer Dylovene. It removes toxins and slightly heals the liver.
    If it is caused by radiation, use Hyronalin or Arithrazine.
    Fix liver and kidneys with surgery, Peridaxon, or cryotubes.

Some toxins are even more dangerous, as they are targeted towards specific organs and bypass the liver's protection. These can go right for the brain if left untreated and are enormously lethal. Be ready to react quickly if you want to have any hope of saving a patient from these super-poisons.

There are a variety of handy tools available to medical personnel. Learning what information can be gathered from each, and what you most need to know, is key to quick and accurate diagnosis.

Triage is the art of quickly diagnosing multiple patients and prioritizing care towards those with the most pressing need. Basically, when you have multiple patients, look over each of them as quickly as you can and figure out which of them, if any, need treatment right the hell now, and focus care on them. This is a vital skill during emergency situations, but even with only one or two patients to look at, being able to determine within a few seconds whether or not their condition is particularly serious is a vital skill, particularly for Medical Technicians, who will often be called upon to exercise this skill in the field while retrieving patients for transport to the Infirmary.

This relies, obviously, on your ability to quickly and accurately diagnose patients, so familiarize yourself with the diagnostic tools covered above and learn how to read them. Once you know how to identify what is wrong with each, it becomes a matter of prioritizing. Any patient undergoing cardiac arrest, suffering from internal bleeding, with ruptured lungs, or experiencing organ failure needs immediate treatment.

Medicines are the true lifeblood of Medical as a department. There are medications available for all but the most severe of injuries; medications that will stitch your flesh back together, or salve your burns, or supply oxygen to your brain, or repair damaged organs, or cleanse toxins from your system. All of them are incredibly useful, and with a proper supply of medication, Medical should be able to save practically anyone that they can reach prior to death, no matter how intense the injury.

Unfortunately, only a small number of medications come readily available in the Infirmary vending machines. Most of them have to be made by hand by the Pharmacist in the Chemistry Lab.

One of the more important medications is

    Inaprovaline has various effects, most important being slowing down rate at which brain takes damage from low oxygenation. It mixes with Dylovene to make Tricordrazine.
    Dylovene is a general purpose anti-toxin that will cleanse various poisonous substances from the blood stream. Dylovene is your go-to answer for toxins of any type. It also heals the liver very slightly, assuming that it isn't already dead. Mixes with Inaprovaline to make Tricordrazine.
    Bicaridine treats brute damage.
    Kelotane treats burn damage. Dermaline is just stronger Kelotane.
    Dexalin will supply blood with oxygen, regardless of if lungs work or not. Dexalin is incredibly useful for stabilizing patients whose lungs have failed, but still requires blood flow.
    Tramadol, a strong painkiller, is useful to prevent pain shock in patients.
    Alkysine repairs brain damage if oxygenation is good. It causes intermittent blackouts and confusion.
    Antidexafen treats bacterial infections. Infection should be treated with antidexafen.
    Citalopram treats depression. Citalopram is a safe and effective anti-depressant.

   If a patient's heart has stopped, there's no blood flow going to the brain. This can quickly result in brain death, and obviously should be corrected as quickly as possible, as mentioned above. However, if, for some reason, immediate resuscitation is not possible, CPR is a good way to extend a patient's life. Every time you perform CPR, it counts as one breath with their lungs were properly working, it circulates blood a little no matter what state heart is in, and with some luck, you might be able to restart their heart. Don't be afraid to crack some ribs while you're at it, remember, if they died with ribs intact, you didn't try hard enough!

Patient is suffering from blunt trauma to the lower extremeties; from trauma to the torso; from trauma to the head;
The patient is suffering from a respiratory infection acquired on an away mission; infection acquired on an exoplanet; infection acquired in the mess hall;
I recommend surgery to stop the bleeding; surgery to improve quality of life; I recommend surgery to; I recommend treatment with; I recommend bed rest; I will prescribe inaprovaline to; I will prescribe bicaridine to; I will prescribe dylovene to;
In my opinion this looks like hypochondria; this looks like acute respiratory distress; this looks like something I saw at medical school,;
Burns should be treated with kelotane; Poisoning should be treated with dylovene; Radiation should be treated with arithrazine;
Adminsister five units of inaprovaline, stat! Adminsister five units of bicaridine, stat! Adminsister five units of dylovene, stat! Start a blood transfusion, stat! Get me a scalpel, stat!
What seems to be the problem? How are you feeling? How long have you felt this way? How did this happen? When did this start? How long has this been going on? What makes you think that? What if you move the affected limb?
What if you apply pressure to the affected area? What are the patient's vitals? What symptoms are you experiencing? Tell me about your symptoms. These symptoms suggest; These symptoms are consistent with a;
Have you seen a doctor about this issue before? I need a complete medical history. I need a complete family history. There isn't enough information to make a diagnosis. Please take a seat in the lobby;
Please don't obstruct the doorways; How are you? How are you feeling? Please give me a detailed medical history. Please give me more information. Please replenish the supply of inaprovaline. Please call for a janitor.
Please keep the hallways clear. Please call the counselor for a consult. Please call the surgeon for a consult. Please call the roboticist for a consult. Please wash your hands.
This looks like arthritis. This looks like chronic fatigue syndrome. This looks like explosive goiter. This looks like decompression sickness. This looks like Unathi flu.
My diagnosis is neuroblastoma. My diagnosis is hiccups. My diagnosis is liver trauma. My diagnosis is space drugs overdose.
The prognosis is good. The prognosis is poor. The prognosis is hard to determine. This requires surgery to correct. This requires exploratory surgery to find out what is really going on. This requires long-term management.
This looks like hypovolemic shock. I prescribe tramadol, since the patient complains of discomfort. I prescribe citalopram, since the patient is combative. I prescribe antidexafen, since the patient has a secondary infection.
The patient complains of discomfort in the lower extremeties. The patient complains of difficult bowel movements. The patient complains about the food in the mess hall. Food poisoning is possible.
It's possibly food poisoning. It's possibly lupus. It's possibly a colonial plot. It's possibly infectious.
The patient needs rest. The patient needs a healthy meal. The patient needs observation. The patient needs quick triage. The patient needs blood transfusion.
This requires a different approach. This requires the cryotube. This requires an experienced surgeon. This requires more advanced facilities.
I recommend citalopram. I recommend shore leave. I recommend a shot of whiskey. I recommend caution. I recommend a prosthetic.
"}

