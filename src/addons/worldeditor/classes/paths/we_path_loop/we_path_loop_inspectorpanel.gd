@tool
extends Control

@onready var but_refresh = $but_refresh

signal refresh


func _ready():
	but_refresh.pressed.connect(refresh_)


func refresh_():
	refresh.emit()
