extends Node2D

func _ready():
	var arr = [1,2,3,4,5]

	arr.remove_at(3)

	for i in arr.size():
		print(arr[i])
