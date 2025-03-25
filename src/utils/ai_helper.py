import os
import json
from openai import OpenAI
from datetime import datetime

# API anahtarını ortam değişkeninden al
api_key = os.getenv('OPENAI_API_KEY')
if not api_key:
    raise ValueError("OPENAI_API_KEY ortam değişkeni ayarlanmamış!")

client = OpenAI(api_key=api_key)

def safe_json_loads(value):
    if isinstance(value, str) and value.strip():
        try:
            return json.loads(value)
        except Exception:
            return []  # veya value'yı olduğu gibi bırakabilirsiniz
    return []

def arazi_tavsiyesi_al(arazi_data):
    """
    Arazi verilerini kullanarak OpenAI'dan tarım tavsiyeleri alır.
    """
    # JSON verilerini parse et
    arazi_data['son_urunler'] = safe_json_loads(arazi_data.get('son_urunler', ''))
    arazi_data['sorunlar'] = safe_json_loads(arazi_data.get('sorunlar', ''))
    arazi_data['ekipmanlar'] = safe_json_loads(arazi_data.get('ekipmanlar', ''))
    arazi_data['don_durumlari'] = safe_json_loads(arazi_data.get('don_durumlari', ''))

    # Prompt oluştur
    prompt = f"""Bir çiftçi için tarım tavsiyeleri verir misin? İşte arazisi hakkında detaylı bilgiler:

Arazi Bilgileri:
- İsim: {arazi_data['adi']}
- Konum: {arazi_data['konum']}
- Büyüklük: {arazi_data.get('buyukluk', 'Belirtilmemiş')} {arazi_data.get('buyukluk_birimi', '')}
- Arazi Yapısı: {arazi_data.get('arazi_yapisi', 'Belirtilmemiş')}
- Arazi Tipi: {arazi_data['arazi_tipi']}

Toprak Özellikleri:
- Toprak Analizi: {arazi_data['toprak_analizi']}
- Toprak Rengi: {arazi_data.get('toprak_rengi', 'Belirtilmemiş')}
- Toprak Yapısı: {arazi_data.get('toprak_yapisi', 'Belirtilmemiş')}
- Taş Durumu: {arazi_data.get('tas_durumu', 'Belirtilmemiş')}
- Su Durumu: {arazi_data.get('su_durumu', 'Belirtilmemiş')}

Sulama Bilgileri:
- Sulama Kaynağı: {arazi_data.get('sulama_kaynagi', 'Belirtilmemiş')}
- Sulama Yöntemi: {arazi_data.get('sulama_yontemi', 'Belirtilmemiş')}

Üretim Bilgileri:
- Son 3 Yılda Ekilen Ürünler: {', '.join(arazi_data.get('son_urunler', ['Belirtilmemiş']))}
- Karşılaşılan Sorunlar: {', '.join(arazi_data.get('sorunlar', ['Belirtilmemiş']))}
- Mevcut Ekipmanlar: {', '.join(arazi_data.get('ekipmanlar', ['Belirtilmemiş']))}
- Çalışan Sayısı: {arazi_data.get('calisan_sayisi', 'Belirtilmemiş')}

İklim Özellikleri:
- Don Durumları: {', '.join(arazi_data.get('don_durumlari', ['Belirtilmemiş']))}

Lütfen şu konularda tavsiyeler ver:
1. Bu arazi için en uygun ürün önerileri
2. Toprak verimliliğini artırmak için öneriler
3. Sulama stratejisi
4. Karşılaşılan sorunlara çözüm önerileri
5. Ekipman ve işgücü optimizasyonu
6. İklim koşullarına göre önlemler
7. Maliyet düşürme ve verim artırma önerileri

Lütfen önerilerini maddeler halinde, açık ve anlaşılır bir şekilde yaz."""
    try:
        response = client.chat.completions.create(
            model="gpt-4o", 
            messages=[
                {"role": "system", "content": "Sen tarım ve çiftçilik konusunda uzman bir ziraat mühendisisin. Çiftçilere pratik ve uygulanabilir tavsiyeler veriyorsun."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=2000
        )
        
        return {
            'tavsiyeler': response.choices[0].message.content,
            'olusturulma_tarihi': datetime.now().isoformat()
        }
        
    except Exception as e:
        return {
            'hata': 'Tavsiye alınırken bir hata oluştu',
            'detay': str(e)
        }
