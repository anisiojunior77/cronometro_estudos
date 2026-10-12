# ⏱️ Cronómetro de Estudos (Study Tracker)

Aplicação mobile/desktop desenvolvida em **Flutter** para ajudar a acompanhar e gerir o tempo dedicado a cada matéria de estudo.

---

## 🚀 Funcionalidades

* **Temporizador em Tempo Real**: Medição precisa de horas, minutos e segundos.
* **Adição de Matérias Personalizadas**: Adicione dinamicamente as disciplinas que deseja estudar sem restrições.
* **Painel de Estatísticas**:
  * Tempo total estudado no dia.
  * Progresso e horas acumuladas na semana.
  * Identificação automática da matéria mais estudada.
* **Histórico de Sessões**: Registo detalhado com data, hora e duração de cada sessão finalizada.
* **Design Moderno**: Interface em modo escuro (Dark Theme) adaptada para dispositivos móveis e desktop.

---

## 🛠️ Tecnologias Utilizadas

* **[Flutter](https://flutter.dev/)** — Framework de desenvolvimento multiplataforma.
* **[Dart](https://dart.dev/)** — Linguagem de programação.
* **[Provider](https://pub.dev/packages/provider)** — Gestão de estado reativa.
* **[Intl](https://pub.dev/packages/intl)** — Formatação de datas e horas.

---

## 📂 Estrutura do Projeto

```text
lib/
├── models/
│   └── study_session.dart   # Modelo de dados da sessão de estudo
├── providers/
│   └── timer_provider.dart  # Lógica do cronómetro e estatísticas
├── screens/
│   ├── timer_screen.dart    # Tela principal do temporizador
│   ├── stats_screen.dart    # Tela de estatísticas e progresso
│   └── history_screen.dart  # Tela do histórico de sessões
└── main.dart                # Ponto de entrada e navegação
