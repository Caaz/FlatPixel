extends Node

const SAVE_FORMAT_STRING = "Saved current project to %s."
const OPEN_FORMAT_STRING = "Opened project %s."
const EXPORT_FORMAT_STRING = "Exported spritesheet to %s."
const RENDER_FORMAT_STRING = "Render completed in %.3f seconds."

signal on_event_reported(event_text: String)

var event_log: Array[String]

func report_event(event: String):
	event_log.append(event)
	on_event_reported.emit(event)

func report_save(filepath: String):
	report_event(SAVE_FORMAT_STRING % filepath)

func report_open(filepath: String):
	report_event(OPEN_FORMAT_STRING % filepath)

func report_export(filepath: String):
	report_event(EXPORT_FORMAT_STRING % filepath)

func report_render(render_result: RenderResult):
	report_event(RENDER_FORMAT_STRING % (render_result.render_duration_ms / 1000.0))
