@tool
extends Control

signal refreshed

@onready var but_refresh = $but_refresh


func _ready():
	but_refresh.pressed.connect(refreshed)


func refresh():
	refreshed.emit()
