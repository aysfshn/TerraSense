# TerraSense Acceptance Tests

## 1. Kullanıcı Kayıt Olma Senaryosu

**Senaryo Başlığı:** Kullanıcı başarılı bir şekilde kayıt olabilmeli

**Ön Koşullar:**
- Kullanıcı kayıt formuna erişim sağlayabilmeli

**Test Adımları:**
1. Kullanıcı kayıt formunu açar
2. Kullanıcı aşağıdaki geçerli bilgileri girer:
   - E-posta: `test@example.com`
   - Şifre: `Sifre123!`
   - Ad: `Test`
   - Soyad: `Kullanici`
   - Telefon: `5051234567` (opsiyonel)
3. Kullanıcı "Kayıt Ol" butonuna tıklar

**Beklenen Sonuçlar:**
1. Sistem kullanıcıyı veritabanına kaydeder
2. Kullanıcıya başarılı kayıt mesajı gösterilir
3. API kayıt isteğine HTTP 201 durum kodu ile yanıt verir
4. Kullanıcı bilgileri yanıtta doğru şekilde döndürülür

**Kabul Kriterleri:**
- HTTP 201 başarı durum kodu alınmalı
- Yanıt JSON formatında ve içerisinde `kullanici` nesnesi bulunmalı
- `kullanici` nesnesinde kullanıcının girdiği bilgiler (şifre hariç) bulunmalı
- Veritabanında kullanıcı kaydı oluşturulmalı

**Metriks:**
- Başarılı kayıt oranı: %98
- Kayıt işlemi tamamlanma süresi: < 2 saniye

---

## 2. Arsa Ekleme Senaryosu

**Senaryo Başlığı:** Kullanıcı başarılı bir şekilde arsa kaydı yapabilmeli

**Ön Koşullar:**
- Kullanıcı sisteme giriş yapmış olmalı
- Kullanıcı geçerli bir JWT token'ına sahip olmalı

**Test Adımları:**
1. Kullanıcı arsa ekleme formunu açar
2. Kullanıcı aşağıdaki geçerli arsa bilgilerini girer:
   - Arsa Adı: `Test Tarlası`
   - Konum: `Ankara, Polatlı`
   - Toprak Analizi: `Tınlı-Killi`
   - Bütçe: `25000`
   - Arazi Tipi: `Tarla`
   - Büyüklük: `15`
   - Büyüklük Birimi: `donum`
   - Arazi Yapısı: `Düz`
   - Toprak Rengi: `Koyu kahverengi`
   - Toprak Yapısı: `Tınlı`
   - Taş Durumu: `Az taşlı`
   - Su Durumu: `Normal`
   - Sulama Kaynağı: `Kuyu`
   - Sulama Yöntemi: `Damla sulama`
   - Son Ürünler: `["Buğday", "Arpa"]`
   - Sorunlar: `["Kuraklık"]`
   - Ekipmanlar: `["Traktör", "Pulluk"]`
   - Çalışan Sayısı: `2`
   - Don Durumları: `["Ocak-Şubat arası"]`
3. Kullanıcı "Arsa Ekle" butonuna tıklar

**Beklenen Sonuçlar:**
1. Sistem arsayı veritabanına kaydeder
2. Kullanıcıya başarılı arsa ekleme mesajı gösterilir
3. API arsa ekleme isteğine HTTP 201 durum kodu ile yanıt verir
4. Arsa bilgileri yanıtta doğru şekilde döndürülür
5. Eklenen arsa kullanıcının arsa listesinde görüntülenir

**Kabul Kriterleri:**
- HTTP 201 başarı durum kodu alınmalı
- Yanıt JSON formatında ve içerisinde `arazi` nesnesi bulunmalı
- `arazi` nesnesinde 'id' değeri ve girilen tüm bilgiler bulunmalı
- Veritabanında arsa kaydı kullanıcının ID'si ile ilişkilendirilmiş olmalı
- Arsa eklendikten sonra kullanıcının arsa listesinde görüntülenmeli

**Metriks:**
- Başarılı arsa ekleme oranı: %95
- Arsa ekleme işlemi tamamlanma süresi: < 3 saniye

---

## 3. Arsaya Özel Soru-Cevap Senaryosu

**Senaryo Başlığı:** Kullanıcı arsasıyla ilgili sorulara özel cevaplar alabilmeli

**Ön Koşullar:**
- Kullanıcı sisteme giriş yapmış olmalı
- Kullanıcının kayıtlı en az bir arsası bulunmalı

**Test Adımları:**
1. Kullanıcı arsa detay sayfasına gider
2. "Tavsiye Al" veya "Soru Sor" butonuna tıklar
3. Sistem arsanın detaylarını AI sistemine gönderir

**Beklenen Sonuçlar:**
1. Arsa bilgileri AI sistemine doğru şekilde iletilir
2. AI sistemi arsa özelliklerine uygun tavsiyeler üretir
3. Sistem, AI'dan aldığı yanıtı kullanıcıya gösterir
4. Yanıt şu kategorileri içerir:
   - Uygun ürün önerileri
   - Toprak verimliliği önerileri
   - Sulama stratejisi
   - Sorunlara çözüm önerileri
   - Ekipman ve işgücü optimizasyonu
   - İklim koşullarına göre önlemler
   - Maliyet düşürme ve verim artırma önerileri

**Kabul Kriterleri:**
- HTTP 200 başarı durum kodu alınmalı
- Yanıt JSON formatında ve içerisinde `tavsiyeler` alanı bulunmalı
- Tavsiyeler, arsa özelliklerine göre özelleştirilmiş ve anlamlı olmalı
- Yanıt süresi makul olmalı (< 10 saniye)
- Hata durumunda kullanıcıya anlamlı bir hata mesajı gösterilmeli

**Metriks:**
- Başarılı tavsiye alma oranı: %90
- Tavsiye alma işlemi tamamlanma süresi: < 8 saniye
- Kullanıcı memnuniyet oranı: %85 (kullanıcı geri bildirimleri ile ölçülür) 