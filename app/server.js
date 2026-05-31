const express = require('express');
const app = express();
const port = 3000;

const htmlContent = `
<!DOCTYPE html>
<html lang="uk">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Дипломний проєкт | Фаховий коледж Оптіма</title>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Montserrat', sans-serif;
            background-color: #f4f7f6;
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        header {
            background-color: #112d4e; /* Корпоративний синій Оптіма */
            color: white;
            padding: 20px 0;
            text-align: center;
            border-bottom: 5px solid #f9a826; /* Жовтий акцент */
        }
        header h1 {
            margin: 0;
            font-size: 28px;
            letter-spacing: 1px;
        }
        .container {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            padding: 40px;
            max-width: 650px;
            text-align: center;
            border-top: 5px solid #3f72af;
        }
        .card h2 {
            color: #112d4e;
            margin-top: 0;
            font-size: 24px;
        }
        .badge {
            display: inline-block;
            background-color: #e5f7ed;
            color: #28a745;
            padding: 10px 20px;
            border-radius: 30px;
            font-weight: 600;
            margin: 20px 0;
            border: 1px solid #c3e6cb;
            font-size: 16px;
        }
        .info-list {
            text-align: left;
            margin-top: 30px;
            line-height: 1.8;
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #f9a826;
        }
        .info-list span {
            font-weight: 600;
            color: #3f72af;
        }
        footer {
            text-align: center;
            padding: 20px;
            background-color: #e2e8f0;
            font-size: 14px;
            color: #666;
        }
    </style>
</head>
<body>
    <header>
        <h1>Фаховий коледж «Оптіма»</h1>
    </header>
    <div class="container">
        <div class="card">
            <h2>Кваліфікаційна робота</h2>
            <div class="badge">✔ CI/CD Pipeline працює ідеально!</div>
            <p>Вітаємо! Цей вебзастосунок було автоматично зібрано та відправлено у хмарну інфраструктуру AWS за допомогою GitHub Actions та Terraform.</p>
            <div class="info-list">
                <div><span>Студентки:</span> Глухенько Валентина</div>
                <div><span>Спеціальність:</span> Комп'ютерні науки</div>
                <div><span>Технології:</span> AWS (VPC, ECR), Terraform, Docker, GitHub Actions</div>
            </div>
        </div>
    </div>
    <footer>
        © 2026 Розроблено в рамках дипломного проєкту
    </footer>
</body>
</html>
`;

app.get('/', (req, res) => {
  res.send(htmlContent);
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});