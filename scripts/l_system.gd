# https://en.wikipedia.org/wiki/L-system
# https://www.youtube.com/watch?v=E1B4UoSQMFw&ab_channel=TheCodingTrain

class_name LSystem # STATIC
# L-system or Lindenmayer system


static func generate(axiom : String, rules : Array[Array],
		generations : int) -> String:
	
	var sentance : String = axiom
	var next_sentance : String = ""
	
	for _iteration in generations:
		for character in sentance:
			var found : bool = false
			
			for rule in rules:
				if character == rule[0]: # character == identity
					found = true
					next_sentance += rule[1]
					break
			
			if not found:
				next_sentance += character
		
		sentance = next_sentance
	
	return sentance
