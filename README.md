## ПКС. Практическая работа №11. Мельников Артемий Алексеевич, ЭФБО-02-22. Добавление Supabase, регистрация и авторизация.
Суть работы заключается в добавлении системы управления авторизацией Supabase в готовый flutter-проект.

Листинг изменённого кода приведён ниже:
```
const supabaseUrl = 'https://xzibhythexmxaquxyrrf.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6aWJoeXRoZXhteGFxdXh5cnJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3MjkwMzUsImV4cCI6MjA1MDMwNTAzNX0.3G1ugfU2rHDco8_e6cjtkn5imz955Z5qR_2MaBDbpGY';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}
```

### Регистрация:
  
![Flutter_11_supabase_reg](https://github.com/user-attachments/assets/0db0f235-a8a7-4a9f-b079-a34bc1add689)

### Авторизация:

![Flutter_11_supabase_auth](https://github.com/user-attachments/assets/d8bce4ae-953c-44c8-903d-7b632c11d7a8)

![Flutter_11_supabase_auth_2](https://github.com/user-attachments/assets/dd3375f8-85b1-4118-a465-d72155c5fd07)

### Информация о пользователях в Supabase:

![Flutter_11_supabase_users](https://github.com/user-attachments/assets/31c16945-b6b4-4e4d-827d-1b0116513436)




