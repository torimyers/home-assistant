#!/usr/bin/env python3
import sys
from shared_state import toggle_daic_mode

if __name__ == "__main__":
    message = toggle_daic_mode()
    print(message)