# Run App On Phone

Muc tieu: chay backend tren may tinh va Flutter app tren dien thoai that cung Wi-Fi.

## 1. Lay IP LAN cua may tinh

PowerShell:

```powershell
ipconfig
```

Lay IPv4 cua card Wi-Fi, vi du `192.168.1.10`.

## 2. Cau hinh Flutter API URL

Sua `Flutter/trellon_flutter/.env`:

```env
API_URL=http://<IP_LAN_CUA_MAY_TINH>:5293/v1/api/
```

Vi du:

```env
API_URL=http://192.168.1.10:5293/v1/api/
```

Khong dung `localhost` hoac `10.0.2.2` khi chay tren dien thoai that.

## 3. Chay backend

```powershell
cd "C#\TodoAppAPI"
dotnet ef database update
dotnet run --launch-profile http
```

Backend can listen o `http://0.0.0.0:5293`.

## 4. Chay Flutter tren dien thoai

Bat USB debugging, cam dien thoai vao may tinh, roi chay:

```powershell
cd "Flutter\trellon_flutter"
flutter devices
flutter run
```

## 5. Neu khong ket noi duoc

- Dien thoai va may tinh phai cung Wi-Fi.
- Cho phep firewall Windows cho port `5293`.
- Kiem tra lai `API_URL` co dung IP LAN khong.
- Sau khi doi `.env`, stop app va `flutter run` lai.
