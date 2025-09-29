class_name GUIBoss
extends PanelContainer

@onready var boss_title: Label = %BossTitle
@onready var boss_description: RichTextLabel = %BossDescription

func update_with_boss_data(boss_data:BossData) -> void:
	boss_title.text = boss_data.display_name
	boss_description.text = boss_data.get_display_description()
