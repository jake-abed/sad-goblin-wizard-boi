class_name Reflection extends Control

signal dialog_chosen(result: String)

@export var player: Player
@export var button_one: Button
@export var button_two: Button
@export var button_three: Button
@export var button_four: Button
@export var reflection_dialog: Label

@onready var dialog_options: Array[Dictionary]= [
	{
		"text": "Gods, I am so freakin' ugly!",
		"response": "Maybe some people think you're ugly, but to hell with them. You're a fine looking gobbo.",
		"result": "debuff_heart"
	},
	{
		"text": "Purple clothes and green skin makes me look like an edgy clown.",
		"response": "Yeah, but that edgy clown gets to fight a bat person or something. Werebat? I don't know.",
		"result": "debuff_attack"
	},
	{
		"text": "I wish I knew better spells than these...",
		"response": "Mr. Tusk was not right about you! You may be a budget wizard to some, but I think you're great.",
		"result": "debuff_talent"
	},
	{
		"text": "My legs are too scrawny under these robes.",
		"response": "You shouldn't have skipped leg day. But it's never too late to start.",
		"result": "debuff_speed"
	},
	{
		"text": "Stupid mirror, waste of time...",
		"response": "Yeah, kind of an ugly mirror and poorly made as well. But it is not a waste of time to talk to it.",
		"result": "debuff_reflection"
	},
	{
		"text": "Why is this mirror even down here?",
		"response": "Who knows? I mean, you chose to come here and check it out, so you must be kind of curious?",
		"result": "nothing"
	},
	{
		"text": "I'm feeling weak, I need a heal.",
		"response": "You should've said so sooner, let's heal you up right away. Fighting shape, my dude!",
		"result": "heal"
	},
	{
		"text": "Is Mr. Tusk even actually a walrus?",
		"response": "He probably isn't actually a walrus. It's probably some Walrus and the carpenter joke he thinks is clever.",
		"result": "buff_reflection"
	},
	{
		"text": "Do you have anything to drink? I'm thirsty.",
		"response": "Uh, I only have healing potions, which I believe means you have a healing potion to drink right now.",
		"result": "heal"
	},
	{
		"text": "Do I look more green than normal? Am I sick?",
		"response": "Not sure, have a swig of a healing potion just in case. Nobody wants you getting sick in here.",
		"result": "heal"
	},
	{
		"text": "I feel like all this running around has made me faster.",
		"response": "It really has. You're building stamina and strength at a pretty fast rate fighting these monsters.",
		"result": "buff_speed"
	},
	{
		"text": "My homemade health potions honestly taste great.",
		"response": "Have a swig of this tasty goodness then, my dude. It does taste good, kinda like POG juice or something.",
		"result": "heal"
	},
	{
		"text": "I haven't really died yet! That's awesome, I must be hardy.",
		"response": "You are! It's a combination of that cool wizard robe and goblins being resistant to psychic dungeon monsters.",
		"result": "buff_heart"
	},
	{
		"text": "I think I could use a heal right about now.",
		"response": "Say no more, fam. Let's heal you right up with a glug-a-lug of potion juice.",
		"result": "heal"
	},
	{
		"text": "My spells seem to be hitting hard than normal.",
		"response": "Your attacks are actually getting stronger. The monsters do not stand a chance against your badassery.",
		"result": "buff_attack"
	},
	{
		"text": "How's my health doing right now?",
		"response": "I don't actually know, but you should chug this potion just in case. Down the hatch!",
		"result": "heal"
	},
	{
		"text": "You know, I enjoy talking to this mirror.",
		"response": "That must mean you enjoy talking to yourself, my dude! No surprise, you're pretty cool.",
		"result": "buff_reflection"
	},
	{
		"text": "Huh, I wonder how much time I've spent down here? I'm having fun.",
		"response": "I'm not sure, but you're having a good time and that's what counts. Seems like you'll be out of here soon though.",
		"result": "nothing"
	},
	{
		"text": "Rainbow spells and sparkle spells are really cool.",
		"response": "Duh! Mr. Tusk is just jealous because the ony spell he knows is magic mouth. And you know how he uses that!",
		"result": "buff_talent"
	},
	{
		"text": "You know what? I am cool. Being a goblin wizard is cool! Rainbows and stars rock!",
		"response": "Hey! You finally get it now... well, my job is done here! You should love yourself no matter what. Who cares what an asshole, rich, fake-walrus thinks. By the way, you can just keep playing if you'd like.",
		"result": "win"
	}
]

@onready var died_dialog: Array[String] = [
	"Uuf, that was walloping. Let's get you back out there, but maybe you should take it a little easier. Keep a safe distance from the danger.",
	"My dude, you are taking hits! Slow it down and fight smart. We'll top your health off and get you back out into an easier room, okay?",
	"Don't forget to level up your Heart stat! That'll help you tank more hits and survive when the going gets rough!"
]

@onready var normal_intro_dialog: Array[String] = [
	"Another floor of this magical dungeon completed. Good job, dude.",
	"Don't worry, I'm not trapped in this mirror. I'm just here to help you while you're in the dungeon.",
	"When you're out of here, you're probably gonna think all of this was super funny. Maybe someone will believe you?",
	"I actually don't remember how you got in here. Did you even walk through a door? Or did you teleport in.",
	"Where'd you learn that teleportation spell? It's pretty cool, all the little poofs of rainbow smoke.",
	"I don't think we're actually in a real room right now. I mean, look around. Is there a room? It's just you and me in here.",
]

@onready var buttons : Array[Button] = [button_one, button_two, button_three, button_four]

var selected_dialogs: Array[Dictionary]
var button_1_dialog: Dictionary
var button_2_dialog: Dictionary
var button_3_dialog: Dictionary
var button_4_dialog: Dictionary

func _ready() -> void:
	button_one.pressed.connect(_on_button_one_pressed)
	button_two.pressed.connect(_on_button_two_pressed)
	button_three.pressed.connect(_on_button_three_pressed)
	button_four.pressed.connect(_on_button_four_pressed)

func reset_after_win() -> void:
	reflection_dialog.text = normal_intro_dialog.pick_random()
	select_dialog_options()
	update_dialog_options()
	show()

func reset_after_death() -> void:
	reflection_dialog.text = died_dialog.pick_random()
	select_dialog_options()
	update_dialog_options()
	show()

func select_dialog_options() -> void:
	var dialog_copy: Array[Dictionary] = dialog_options.duplicate(true)
	button_1_dialog = dialog_copy.pop_at(choose_index(dialog_copy))
	button_2_dialog = dialog_copy.pop_at(choose_index(dialog_copy))
	button_3_dialog = dialog_copy.pop_at(choose_index(dialog_copy))
	button_4_dialog = dialog_copy.pop_at(choose_index(dialog_copy))

func update_dialog_options() -> void:
	button_one.text = button_1_dialog["text"]
	button_two.text = button_2_dialog["text"]
	button_three.text = button_3_dialog["text"]
	button_four.text = button_4_dialog["text"]
	enable_all_buttons()

func choose_index(dialogs: Array) -> int:
	var index := randi_range(-5, 5) + int(player.reflection)
	if index < 0:
		index = 0
	if index > dialogs.size() - 1:
		index = dialogs.size() - 1
	return index

func enable_all_buttons() -> void:
	for button in buttons:
		button.disabled = false

func disable_all_buttons() -> void:
	for button in buttons:
		button.disabled = true

func _on_button_one_pressed() -> void:
	disable_all_buttons()
	reflection_dialog.text = button_1_dialog["response"]
	var tween := create_tween()
	tween_refelection_text(tween)
	await tween.finished
	dialog_chosen.emit(button_1_dialog["result"])

func _on_button_two_pressed() -> void:
	disable_all_buttons()
	reflection_dialog.text = button_2_dialog["response"]
	var tween := create_tween()
	tween_refelection_text(tween)
	await tween.finished
	dialog_chosen.emit(button_2_dialog["result"])

func _on_button_three_pressed() -> void:
	disable_all_buttons()
	reflection_dialog.text = button_3_dialog["response"]
	var tween := create_tween()
	tween_refelection_text(tween)
	await tween.finished
	dialog_chosen.emit(button_3_dialog["result"])

func _on_button_four_pressed() -> void:
	disable_all_buttons()
	reflection_dialog.text = button_4_dialog["response"]
	var tween := create_tween()
	tween_refelection_text(tween)
	await tween.finished
	dialog_chosen.emit(button_4_dialog["result"])

func tween_refelection_text(tween: Tween) -> void:
	reflection_dialog.visible_ratio = 0.0
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_parallel(false)
	tween.tween_property(reflection_dialog, "visible_ratio", 1.0, 2.5)
	tween.tween_property(reflection_dialog, "visible_ratio", 1.0, 3.5)
