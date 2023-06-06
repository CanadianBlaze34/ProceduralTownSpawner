class_name PathGenerator # STATIC


static func generate() -> String:
	
	var generations : int = 4
	var axiom : String = "F"
	
	var rule_1 : Array = ["F", "FF+[F-F-F]-[-F+F+F]"]
	var rules : Array[Array] = [rule_1]
	
	var start := Time.get_ticks_msec()
	var sentance : String = LSystem.generate(axiom, rules, generations)
	var duration : float = (Time.get_ticks_msec() - start) / 1000.0
	print("LSystem Generation duration: %f seconds." % [duration])
	
	
	return sentance

