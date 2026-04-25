extends PanelContainer

signal selected(upgrade_data)
var current_upgrade_data : UpgradeData

func setup(data: UpgradeData):
	current_upgrade_data = data
	$Button/VBoxContainer/NameLabel.text = data.name
	$Button/VBoxContainer/DescriptionLabel.text = data.description
	#$Button/VBoxContainer/LevelLabel.text = 
	if data.icon:
		$Button/VBoxContainer/Icon.texture = data.icon
	# On peut aussi ajouter une couleur selon le type (ex: rouge pour dégâts)

func _on_button_pressed():
	selected.emit(current_upgrade_data)
