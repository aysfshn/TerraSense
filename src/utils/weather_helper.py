import os
import json
from datetime import datetime
import requests
from flask import jsonify

# OpenWeatherMap API anahtarı
api_key = "a80e187bb02d656397186ff27c6d42ae"

def hava_durumu_helper(arazi_data):
    konum = arazi_data['konum']
    konum = konum.split('/')
    sehir = konum[0]

    BASE_URL = "http://api.openweathermap.org/data/2.5/weather?"

    url = BASE_URL + "appid=" + api_key + "&q=" + sehir

    response = requests.get(url)
    

    if response.status_code != 200:
        return jsonify({"hata": "Hava durumu bilgisi alınamadı!"}), 500

    veri = response.json()

    return hava_durumu_parse(veri)


def hava_durumu_parse(veri):
    hava_durumu_ceviri = {
        "clear sky": "Açık hava",
        "few clouds": "Az bulutlu",
        "scattered clouds": "Dağınık bulutlu",
        "broken clouds": "Parçalı bulutlu",
        "overcast clouds": "Kapalı hava",
        "mist": "Sisli",
        "fog": "Yoğun sis",
        "haze": "Puslu",
        "smoke": "Dumanlı",
        "dust": "Tozlu",
        "sand": "Kum fırtınası",
        "ash": "Volkanik kül",
        "squalls": "Sağanak rüzgar",
        "tornado": "Kasırga",
        "light rain": "Hafif yağmur",
        "moderate rain": "Orta şiddette yağmur",
        "heavy rain": "Kuvvetli yağmur",
        "very heavy rain": "Çok kuvvetli yağmur",
        "extreme rain": "Şiddetli yağmur",
        "freezing rain": "Donan yağmur",
        "shower rain": "Sağanak yağmur",
        "light drizzle": "Hafif çiseleme",
        "drizzle": "Çiseleme",
        "heavy drizzle": "Yoğun çiseleme",
        "light snow": "Hafif kar yağışı",
        "snow": "Kar yağışı",
        "heavy snow": "Yoğun kar yağışı",
        "sleet": "Karla karışık yağmur",
        "light shower sleet": "Hafif karla karışık yağmur",
        "shower sleet": "Karla karışık sağanak yağmur",
        "light rain and snow": "Hafif yağmur ve kar",
        "rain and snow": "Yağmur ve kar",
        "light shower snow": "Hafif sağanak kar",
        "shower snow": "Sağanak kar",
        "heavy shower snow": "Yoğun sağanak kar",
        "thunderstorm": "Gök gürültülü fırtına",
        "thunderstorm with light rain": "Hafif yağmurlu gök gürültülü fırtına",
        "thunderstorm with rain": "Yağmurlu gök gürültülü fırtına",
        "thunderstorm with heavy rain": "Kuvvetli yağmurlu gök gürültülü fırtına",
        "thunderstorm with light drizzle": "Hafif çiseli gök gürültülü fırtına",
        "thunderstorm with drizzle": "Çiseli gök gürültülü fırtına",
        "thunderstorm with heavy drizzle": "Yoğun çiseli gök gürültülü fırtına"
    }

    try:
        nem = veri["main"]["humidity"]  # Nem oranı (%)
        ruzgar_hizi = veri["wind"]["speed"]  # Rüzgar hızı (m/s)
        sicaklik = round(veri["main"]["temp"] - 273.15, 2)  # Kelvin'den Celsius'a çevirme
        genel_hava = veri["weather"][0]["description"]  # Genel hava durumu (bulutlu, güneşli vs.)
        genel_hava_tur = hava_durumu_ceviri.get(genel_hava, "Bilinmeyen hava durumu")
        
        return {
            "nem": nem,
            "ruzgar_hizi": ruzgar_hizi,
            "sicaklik": sicaklik,
            "genel_hava": genel_hava_tur
        }
    
    except KeyError as e:
        return {"hata": f"Beklenen veri eksik: {e}"}
