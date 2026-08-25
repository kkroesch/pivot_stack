# /// script
# dependencies = [
#     "duckdb==1.5.5",
#     "marimo",
#     "numpy==2.5.2",
#     "pandas==3.0.5",
#     "plotly==6.9.0",
# ]
# requires-python = ">=3.14"
# ///

import marimo

__generated_with = "0.24.0"
app = marimo.App(width="medium")


@app.cell
def _():
    import duckdb
    import marimo as mo

    PARQUET_FILE = "who_air_quality.parquet"

    df = duckdb.query(f"SELECT * FROM '{PARQUET_FILE}'").df()

    table = mo.ui.table(df, pagination=True, page_size=15)
    table
    return


app._unparsable_cell(
    """
    import plotly.express as px

    map_df = duckdb.query(\"\"\"
        SELECT 
            \"city\" AS city,
            \"country_name\" AS country,
            TRY_CAST(\"latitude\" AS DOUBLE) AS lat,
            TRY_CAST(\"longitude\" AS DOUBLE) AS lon,
            TRY_CAST(\"pm25_concentration\" AS DOUBLE) AS pm25
        FROM 'who_air_quality.parquet'
        WHERE lat IS NOT NULL 
          AND lon IS NOT NULL 
          AND pm25 IS NOT NULL
    \"\"\").df()

    # Plotly OpenStreetMap Scatter Map
    fig = px.scatter_mapbox(
        map_df,
        lat=\"lat\",
        lon=\"lon\",
        color=\"pm25\",
        size=\"pm25\",
        hover_name=\"city\",
        hover_data={\"country\": True, \"pm25\": True, \"lat\": False, \"lon\": False},
        color_continuous_scale=\"Reds\",
        zoom=2,
        mapbox_style=\"carto-positroncarto-positron\",\",
        height=600,
    )

    # Als reaktives Marimo UI-Element rendern
    map_view = mo.ui.plotly(fig)
    map_view
    """,
    name="_"
)


if __name__ == "__main__":
    app.run()
