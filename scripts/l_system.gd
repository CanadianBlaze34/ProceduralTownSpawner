# https://en.wikipedia.org/wiki/L-system
# https://www.youtube.com/watch?v=E1B4UoSQMFw&ab_channel=TheCodingTrain

class_name LSystem # STATIC
# L-system or Lindenmayer system

static func generate(axiom : String, rules : Array[Array]) -> String:
	
	var sentance : String = ""
	
#	for rule in rules:
#		sentance = axiom.replacen(rule[0], rule[1])
	
	for character in axiom:
		var found : bool = false
		
		for rule in rules:
			if character == rule[0]: # character == identity
				found = true
				sentance += rule[1]
				break
		
		# character has not been replaced with something else
		if not found:
			sentance += character
	
	return sentance


static func generate_generations(axiom : String, rules : Array[Array],
		generations : int) -> String:
	
	var sentance : String = axiom
	
	for _iteration in generations:
		var next_sentance : String = generate(sentance, rules)
		sentance = next_sentance
	
	return sentance
