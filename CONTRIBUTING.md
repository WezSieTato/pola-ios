### 1. Chciałbyś zgłosić błąd lub zaproponować nową funkcjonalność?

Wpierw [sprawdź](https://github.com/KlubJagiellonski/pola-ios/issues) czy już ktoś wcześniej nie zgłosił podobnego rozwiązania.

Jeżeli nie, to śmiało, [stwórz nowe issue](https://github.com/KlubJagiellonski/pola-ios/issues/new)!

### 2. Fork i tworzenie brancha

Jeżeli jest coś co chciałbyś poprawić/dodać to [zrób forka Poli](https://help.github.com/articles/fork-a-repo)
oraz stwórz branch'a z opisową nazwą.

Do nazewnictwa brancha zastosuj prefixowanie `fix/` lub `feature/` wraz z numerem issues'a i krótkim opisem (najlepiej po angielsku), przykładowo:
```sh
git checkout -b feature/423_added_new_feature
```

### 3. Konfiguracja aplikacji

Wykorzystujemy [CocoaPods](https://cocoapods.org) jako narzędzie do pobierania i konfigurowania zależności.
Do uruchamiana testów i linterów na CI oraz lokalnie używamy [fastlane](https://fastlane.tools/).
W testach wykorzystywane jest porównywanie snapshotów z uzyciem biblioteki [iOSSnapshotTestCase](https://github.com/uber/ios-snapshot-test-case). Snapshoty nagrane są na symulatorze urządzenia iPhone 8 z systemem iOS 13.6, do nagrywania wykorzystano system macOS Mohave.
W przypadku niepowodzenia testów snapshoty ze wskazaniem różnicy przechowywane są w artefaktach Github Actions.
Jeśli masz problem z nagraniem przechodzących snapshotów nie bój się wystawić PR, pomożemy :) 

### 4. Stwórz Pull Request'a

Preferujemy metodę rebase & squash przed samym stworzeniem PR. 
Oznacza to, że branch na którym pracujesz powinien mieć jak najmniej commitów (przy małych zmianach tylko jeden) oraz powinien odchodzić od najnowszego commita na masterze.

Gdy już masz to gotowe [stwórz PR](https://help.github.com/articles/creating-a-pull-request)

### 5. Merge PR (tylko opiekunowie)

PR może być tylko zmergowany gdy:

* Został zaakceptowany przez opiekuna.
* Wszystkie komentarze zostały zamknięte/zakończone.
* Branch odchodzi od najnowszego master.
* Zmiany zostały pomyślnie zbudowane i przetestowane przez serwer [CI](https://travis-ci.org/KlubJagiellonski/pola-ios).

### 6. Wydawanie aplikacji (tylko opiekunowie)

Przed zbudowaniem aplikacji do wydania należy:

 * Skonfigurować Firebase:
    * Pobieramy plik `GoogleService-Info.plist` dla projektu Pola z [konsoli Firebase](https://console.firebase.google.com).
    * Edytujemy plik zmieniając wartość dla klucza `IS_ANALYTICS_ENABLED` na `YES`.
    * Dodajemy plik do projektu.
    * Pliku, ani powyższych zmian nie dodajemy do repozytorium!

* Ustawić odpowiednią wersję:
    * Ustawiamy wcześniej ustaloną z zespołem wersję aplikacji (pole `Version`).
    * Zwiększamy o jeden numer budowania (pole `Build`). Każdorazowe wysłanie aplikacji do [App Store Connect](ttps://appstoreconnect.apple.com) powinno skutkować zwiększeniem tej liczby.
    * Nagrywamy na nowo testy dla klasy `InformationPageUITests`.
    * Powyższe zmiany powinny znaleźć się w repozytorium!
