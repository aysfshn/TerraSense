import requests

BASE_URL = "http://127.0.0.1:5000"

def main():
   
    # 1) Kullanıcı giriş (token elde etme)
    login_payload = {
        "email": "test@gmail.com",
        "password": "123456"
    }
    print("\n=== 1) Giriş İsteği Gönderiliyor... ===")
    r = requests.post(f"{BASE_URL}/auth/giris", json=login_payload)
    print("Cevap:", r.status_code, r.json())
    
    if r.status_code != 200:
        print("Giriş yapılamadı, senaryo devam etmeyecek.")
        return
    
    token = r.json().get("token")
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2) Arsa listeleme
    print("\n=== 2) Arsa Listeleme İsteği Gönderiliyor... ===")
    r = requests.get(f"{BASE_URL}/arazi/", headers=headers)
    print("Cevap:", r.status_code, r.json())
    
    # 3) Arsa ekleme
    #   Gerekli alanlar: ['adi', 'konum', 'toprak_analizi', 'butce', 'arazi_tipi']
    arazi_ekle_payload = {
    "adi": "Örnek Arazi",
    "konum": "Ankara, Polatlı",
    "toprak_analizi": "pH: 6.5, Organik Madde: %2",
    "butce": 100000.0,
    "arazi_tipi": "Tarla",
    "buyukluk": 50.5,
    "buyukluk_birimi": "donum",
    "arazi_yapisi": "Düz",
    "toprak_rengi": "Koyu kahverengi",
    "toprak_yapisi": "Tınlı",
    "tas_durumu": "Az taşlı",
    "su_durumu": "Normal",
    "sulama_kaynagi": "Kuyu",
    "sulama_yontemi": "Damla sulama",
    "son_urunler": ["Buğday", "Arpa", "Mısır"],
    "sorunlar": ["Yabani ot", "Böcek istilası"],
    "ekipmanlar": ["Traktör", "Pulluk", "Mibzer"],
    "calisan_sayisi": 5,
    "don_durumlari": ["Ocak", "Şubat"]
}
    print("\n=== 3) Arsa Ekleme İsteği Gönderiliyor... ===")
    r = requests.post(f"{BASE_URL}/arazi/", json=arazi_ekle_payload, headers=headers)
    print("Cevap:", r.status_code, r.json())
    
    if r.status_code != 201:
        print("Arsa eklenemedi, senaryo devam etmeyecek.")
        return
    
    arsa_id = r.json()["arazi"]["id"]  # Yeni eklenen arsanın ID'si


    # 4) Arsa listeleme
    print("\n=== 4) Arsa Listeleme İsteği Gönderiliyor... ===")
    r = requests.get(f"{BASE_URL}/arazi/", headers=headers)
    print("Cevap:", r.status_code, r.json())

if __name__ == "__main__":
    main()
