# TerraSense Acceptance Test Suite

Bu test paketi, TerraSense API'sinin kabul kriterlerini doğrulamak için otomatik testler içerir. Testler, uygulamanın ana işlevselliklerinin doğru çalıştığını ve kullanıcı kabul kriterlerini karşıladığını doğrulamak için geliştirilmiştir.

## Test Edilen Senaryolar

Kabul testleri üç ana senaryoya odaklanır:

1. **Kullanıcı Kayıt İşlemleri**: Kullanıcı kaydı, giriş ve kullanıcı bilgileri yönetimi
2. **Arazi Yönetimi**: Arazi ekleme, listeleme, güncelleme ve silme işlemleri
3. **Arazi-AI Etkileşimi**: Kullanıcının arazi verilerine dayalı özelleştirilmiş AI tavsiyeleri alması

## Test Dosyaları

Test paketi aşağıdaki dosyalardan oluşur:

- `test_fixtures.py`: Test ortamı için ortak fixture'lar
- `test_user_registration.py`: Kullanıcı kayıt ve kimlik doğrulama testleri
- `test_arazi_management.py`: Arazi CRUD işlemleri testleri
- `test_arazi_ai_interaction.py`: AI tavsiye ve soru-cevap testleri
- `test_acceptance.py`: Entegrasyon testleri

## Gereksinimler

Testleri çalıştırmak için aşağıdaki yazılımların kurulu olması gerekir:

- Python 3.8 veya daha yeni
- pytest
- requests

## Kurulum

Testleri çalıştırmak için gerekli paketleri yükleyin:

```bash
pip install pytest requests
```

## Testleri Çalıştırma

### Tüm testleri çalıştırmak için:

```bash
pytest
```

### Belirli bir test grubunu çalıştırmak için:

```bash
pytest test_user_registration.py
pytest test_arazi_management.py
pytest test_arazi_ai_interaction.py
```

### Ayrıntılı çıktılarla çalıştırmak için:

```bash
pytest -v
```

### Test sırasında çıktıları görmek için:

```bash
pytest -v -s
```

## Test Ortamı Yapılandırması

Test ortamını yapılandırmak için aşağıdaki ortam değişkenlerini kullanabilirsiniz:

- `API_BASE_URL`: API'nin temel URL'i (varsayılan: http://localhost:5000)

Ortam değişkenlerini ayarlamak için:

```bash
# Windows
set API_BASE_URL=http://localhost:8000

# macOS/Linux
export API_BASE_URL=http://localhost:8000
```

## Kabul Kriterleri

Her test grubu, kabul kriterlerini doğrulamak için tasarlanmıştır:

### 1. Kullanıcı Kayıt İşlemleri

- HTTP 201 başarı durum kodu
- JSON yanıt formatı ve `kullanici` nesnesi
- Kullanıcı bilgilerinin doğru kaydedilmesi
- Şifrelerin güvenli saklanması
- Kayıt işlemi süresi < 2 saniye

### 2. Arazi Yönetimi

- HTTP 201 başarı durum kodu
- JSON yanıt formatı ve `arazi` nesnesi
- Arazi bilgilerinin doğru kaydedilmesi
- Kullanıcı ile arazi ilişkisinin kurulması
- Listeleme, güncelleme ve silme işlemlerinin doğru çalışması
- Arazi ekleme işlemi süresi < 3 saniye

### 3. Arazi-AI Etkileşimi

- HTTP 200 başarı durum kodu
- JSON yanıt formatı ve `tavsiyeler` alanı
- Arazi özelliklerine özgü tavsiyelerin üretilmesi
- Tavsiyelerin beklenen kategorileri içermesi
- Yanıt süresi < 10 saniye
- Hata durumlarının uygun şekilde işlenmesi

## Test Raporları

HTML formatında test raporu oluşturmak için:

```bash
pytest --html=rapor.html
```

## Sorun Giderme

- Eğer API bağlantı hatası alıyorsanız, API_BASE_URL ortam değişkeninin doğru ayarlandığından emin olun
- Kimlik doğrulama hataları için, test kullanıcısı oluşturma API'sinin çalıştığından emin olun
- Zaman aşımı hataları için, API'nin yanıt verme süresini uzatmayı deneyin 