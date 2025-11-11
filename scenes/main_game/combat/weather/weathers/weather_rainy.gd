class_name WeatherRainy
extends Weather

func animate_in() -> void:
	await super.animate_in()
	Events.request_constant_water_wave_update.emit(0.1)

func animate_out() -> void:
	await super.animate_out()
	Events.request_constant_water_wave_update.emit(-0.1)
