#!/usr/bin/env python3
"""
MedBox MQTT Pill Box Simulator

Simulates a physical 7-slot pill box (Mon–Sun) that reports slot states via MQTT.
Each slot starts with a pill present. Every 5 seconds one slot is randomly "taken"
(pill removed). Every 60 seconds all slots are restocked.

Usage:
    pip install paho-mqtt
    python mqtt_publisher.py
    python mqtt_publisher.py --take-interval 3 --restock-interval 30
"""

import argparse
import json
import random
import time

import paho.mqtt.client as mqtt

BROKER = "localhost"
PORT = 1883
TOPIC = "medbox/sensor/pillbox"
CLIENT_ID = "medbox_python_publisher"

DAYS = [
    {"id": 1, "label": "Пн"},
    {"id": 2, "label": "Вт"},
    {"id": 3, "label": "Ср"},
    {"id": 4, "label": "Чт"},
    {"id": 5, "label": "Пт"},
    {"id": 6, "label": "Сб"},
    {"id": 7, "label": "Нд"},
]


def build_payload(slots: list[bool]) -> str:
    return json.dumps(
        {
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "slots": [
                {"id": d["id"], "label": d["label"], "has_pill": slots[i]}
                for i, d in enumerate(DAYS)
            ],
        },
        ensure_ascii=False,
    )


def on_connect(client, userdata, flags, reason_code, properties):
    status = "OK" if reason_code == 0 else f"failed (code {reason_code})"
    print(f"[{time.strftime('%H:%M:%S')}] Connected to {BROKER}:{PORT} — {status}")


def main():
    parser = argparse.ArgumentParser(description="MedBox MQTT Pill Box Simulator")
    parser.add_argument(
        "--take-interval",
        type=float,
        default=5.0,
        help="Seconds between pill-taken events (default: 5)",
    )
    parser.add_argument(
        "--restock-interval",
        type=float,
        default=60.0,
        help="Seconds between full restocks (default: 60)",
    )
    args = parser.parse_args()

    client = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2,
        client_id=CLIENT_ID,
        clean_session=True,
    )
    client.on_connect = on_connect
    client.connect(BROKER, PORT, keepalive=60)
    client.loop_start()

    slots = [True] * 7  # all slots have pills initially
    last_restock = time.time()

    def publish(action_msg: str):
        payload = build_payload(slots)
        result = client.publish(TOPIC, payload, qos=1, retain=True)
        result.wait_for_publish(timeout=5)
        filled = sum(slots)
        print(
            f"[{time.strftime('%H:%M:%S')}] {action_msg} "
            f"({filled}/7 пігулок залишилось) → опубліковано"
        )

    # publish initial state immediately
    publish("Початковий стан")

    try:
        while True:
            time.sleep(args.take_interval)

            now = time.time()

            # restock if interval elapsed
            if now - last_restock >= args.restock_interval:
                slots = [True] * 7
                last_restock = now
                publish("Поповнення: всі пігулки повернуто")
                continue

            # pick a random slot that still has a pill
            available = [i for i, has_pill in enumerate(slots) if has_pill]
            if not available:
                print(
                    f"[{time.strftime('%H:%M:%S')}] Усі пігулки вже прийняті — "
                    f"очікування поповнення..."
                )
                continue

            idx = random.choice(available)
            slots[idx] = False
            label = DAYS[idx]["label"]
            publish(f"Слот {idx + 1} ({label}): пігулку прийнято")

    except KeyboardInterrupt:
        print("\nЗупинка симулятора...")
    finally:
        client.loop_stop()
        client.disconnect()
        print("З'єднання закрито.")


if __name__ == "__main__":
    main()
