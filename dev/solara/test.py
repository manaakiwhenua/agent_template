import ipywidgets as widgets

import solara

clicks = 0


def on_click(button):
    global clicks
    clicks += 1
    button.description = f"Clicked {clicks} times"


button = widgets.Button(description="Clicked 0 times")
button.on_click(on_click)

page = widgets.VBox(
    [
        button,
        # using .widget(..) we can create a classic ipywidget from a solara component
        solara.FileDownload.widget(data="some text data", filename="solara-demo.txt"),
    ]
)
