extends Node


var departments = {
	
	'tortilla': 'bread',
	'spaghetti': 'bread',
	'instant_noodles': 'bread',
	'mak_and_cheese': 'bread',
	
	'schlamey': 'canned',
	'hot_sauce': 'canned',
	'tomato_soup': 'canned',
	'canned_beans': 'canned',
	'instant_coffee': 'canned',
	
	'toy_robot': 'toys',
	
	'apple_pie': 'bakery',
	'pizza_dough': 'bakery',
	'brownies': 'bakery',
	
	'apple_juice': 'drinks',
	
	'red_wine': 'wine',
	'white_wine': 'wine',
	
	'milk': 'dairy',
	
	'ham': 'meat',
	'bacon': 'meat',
	'chicken_breast': 'meat',
	'hamburger_patties': 'meat',
	'hot_dogs': 'meat',
	
	'beer': 'beer',
	
	'cups': 'cookware',
	
	'soda': 'cafe',
}


func stylize_text(text: String) -> String:
	# Replace underscores with spaces
	var processed_text = text.replace("_", " ")
	# Capitalize the first letter of each word
	processed_text = processed_text.capitalize()
	return processed_text
