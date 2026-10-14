"""Build the compact in-app catalog from USDA FNDDS 2021-2023 JSON ZIP.

Source: https://fdc.nal.usda.gov/download-datasets/
Usage: python3 scripts/build_usda_catalog.py path/to/FoodData_Central_survey_food_json_2024-10-31.zip
"""

import json
import sys
import zipfile
from pathlib import Path


def build(source: Path, destination: Path) -> None:
    with zipfile.ZipFile(source) as archive:
        foods = json.loads(archive.read("surveyDownload.json"))["SurveyFoods"]

    catalog = []
    for food in foods:
        nutrients = {
            entry["nutrient"]["id"]: entry["amount"]
            for entry in food.get("foodNutrients", [])
            if "amount" in entry
        }
        # Values in FNDDS are per 100 g. Skip records without all four macros.
        if not all(key in nutrients for key in (1003, 1004, 1005, 1008)):
            continue
        catalog.append(
            {
                "id": food["fdcId"],
                "name": food["description"],
                "kcal": nutrients[1008],
                "pro": nutrients[1003],
                "fat": nutrients[1004],
                "cho": nutrients[1005],
            }
        )

    catalog.sort(key=lambda food: (food["name"].casefold(), food["id"]))
    destination.write_text(json.dumps(catalog, ensure_ascii=False, separators=(",", ":")))
    print(f"Wrote {len(catalog)} USDA foods to {destination}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: build_usda_catalog.py source.zip")
    build(
        Path(sys.argv[1]),
        Path(__file__).resolve().parents[1] / "Mkcals/M-Cals/USDA_FNDDS_Foods.json",
    )
