# taubenturret - An automated, computer vision driven water turret system.
# Copyright (C) 2026 Michael Weber
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()

API_HOST: str = os.getenv("API_HOST", "0.0.0.0")  # noqa: S104
API_PORT: int = int(os.getenv("API_PORT", "8081"))
SAVE_IMAGES: str = os.getenv("SAVE_IMAGES", "detection")
IMAGES_DIR: Path = Path(os.getenv("IMAGES_DIR", "./images"))
LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO").upper()

# Name of the input YOLO weight/ checkpoint used for export.
# Examples: yolo11n.pt, yolo26n.pt, path/to/custom.pt
YOLO_MODEL: str = os.getenv("YOLO_MODEL", "yolo11n.pt")

# Final OpenVINO model directory that the backend loads at runtime.
# Keep this fixed so the backend can stay agnostic to the source model version.
YOLO_OPENVINO_MODEL: str = os.getenv("YOLO_OPENVINO_MODEL", "yolo_openvino_model")
