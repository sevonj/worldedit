@tool
extends Control

signal updated

@onready var but_refresh = $but_refresh


func _ready():
	but_refresh.pressed.connect(refresh)


func refresh():
	updated.emit()
