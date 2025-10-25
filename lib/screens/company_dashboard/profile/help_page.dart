import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POT Application – FAQ'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // --- Раздел: Регистрация и Вход ---
          FAQHeader(title: 'Sign in and Sign up'),

          FAQItem(
            question: 'How can I register as an organization and receive a unique promo code?',
            answer:
            '• Click “Register as Organization.”\n'
                '• Enter the organization’s official name, email address, and password (minimum 6 characters, including uppercase, lowercase, numbers, and symbols).\n'
                '• The system will automatically generate a unique promo code, which will be sent to your email address.\n'
                '• You can use this promo code to link new employee accounts to your organization.\n'
                'Tip: Keep your promo code confidential and share it only with trusted employees.',
          ),

          FAQItem(
            question: 'How can I register as an employee using a promo code?',
            answer:
            '• Select “Register as Employee.”\n'
                '• Enter your first name, last name, email address, and password.\n'
                '• Enter the organization’s promo code.\n'
                '• Click “Register,” and your employee profile will automatically open.',
          ),

          FAQItem(
            question: 'How do I log in to an already registered account?',
            answer:
            '• Log in using your registered email address and password.\n'
                '• Your employee or organization dashboard will open automatically, displaying your tasks, working hours, and personal data.',
          ),

          FAQItem(
            question: 'How can I log in using both the mobile and web versions simultaneously?',
            answer:
            '• The same account can be used on both mobile and web versions.\n'
                '• All data is automatically synchronized across both platforms while maintaining full security.',
          ),

          FAQItem(
            question: 'What is a promo code, and why is it needed?',
            answer:
            '• A promo code uniquely links an employee to their organization.\n'
                '• For example, the code 64-42-41 automatically assigns an employee to the corresponding organization’s list.\n'
                '• This ensures managed, secure, and fast access to the system.',
          ),

          // --- Раздел: Безопасность и Пароли ---
          FAQHeader(title: 'Security and password'),

          FAQItem(
            question: 'How can I recover a forgotten password?',
            answer:
            '• Click the “Forgot Password” button.\n'
                '• Enter your registered email address.\n'
                '• The system will send you a recovery link with a temporary password.\n'
                '• Log in and set a new password.',
          ),

          FAQItem(
            question: 'How can I change my password securely?',
            answer:
            '• Go to Profile → Change Password → Enter your old and new password.\n'
                '• The system will automatically confirm the change and block the use of the previous password.',
          ),

          FAQItem(
            question: 'How can I protect my personal and organizational data?',
            answer:
            '• Use passwords that contain uppercase and lowercase letters, numbers, and symbols.\n'
                '• Share your promo code only with trusted individuals.\n'
                '• Never share your password outside your registered email channel.',
          ),

          FAQItem(
            question: 'How can I ensure the security of employee data?',
            answer:
            '• All data is stored in encrypted form, accessible only to authorized users.\n'
                '• The system uses SSL certificates and multi-layer access control.',
          ),

          FAQItem(
            question: 'How to store employee work data with the highest level of security',
            answer:
            '• Poti uses multi-layer encryption, keeping all data encrypted.\n'
                '• SSL certificates ensure secure data transmission over the Internet.\n'
                '• Access control - multi-level - some data is available only to authorized users.\n'
                '• Recently used passwords and login history are automatically stored with a high level of security, so that the source of each login can be tracked.\n'
                'Tip: Use multi-factor authentication, strong passwords (more than 6 characters, uppercase, lowercase, numbers, symbols) and change passwords occasionally to ensure security.',
          ),

          // --- Раздел: Управление Сотрудниками ---
          FAQHeader(title: 'Staff control'),

          FAQItem(
            question: 'How can I add new employees?',
            answer:
            '• Go to the Organization Page → Add Employee.\n'
                '• Enter the employee’s name, email address, and promo code.\n'
                '• The employee is automatically added to the organization list.',
          ),

          FAQItem(
            question: 'How to add a new employee and link them to the organization with a promo code?',
            answer:
            'When registering in POT, the employee enters the organization’s promo code, linking their account to your organization.\n'
                'Go to “Employees” → “Add employee” → Fill in first name, last name, email, and status.\n'
                'The employee appears in the organization’s list with task and schedule tracking.',
          ),

          FAQItem(
            question: 'How to add a new employee in real time?',
            answer:
            '1. Organization page → “Add employee”.\n'
                '2. Enter first name, last name, email, password, and promo code.\n'
                '3. Employee is instantly linked; schedule updates in real time.',
          ),

          FAQItem(
            question: 'How can I edit employee details?',
            answer:
            '• Click on the employee’s name → Edit → Save.',
          ),

          FAQItem(
            question: 'How to edit an employee’s personal data and work status?',
            answer:
            'Click on the employee’s name → “Edit data” → Change fields (email, phone, hours, tasks).\n'
                'Change status: “Working”, “Break”, “Vacation”.\n'
                'System automatically updates schedule with colors: green – working, orange – break, red – away.',
          ),

          FAQItem(
            question: 'How to remove an employee or suspend their access?',
            answer:
            'Click on employee’s name → “Remove employee” → Confirm.\n'
                'System encrypts their data and removes them from the list.',
          ),

          // --- Раздел: Расписание и Статус ---
          FAQHeader(title: 'Work Time,Status'),

          FAQItem(
            question: 'How can I view working hours and current status?',
            answer:
            '• Go to Schedule Section → Designated Fields.\n'
                ' ◦ Green – Working\n ◦ Red – Not working\n ◦ Orange – On break',
          ),

          FAQItem(
            question: 'How to track an employee’s working hours and current status?',
            answer:
            'Select the employee in the graphic section → View start, end, and current status.\n'
                'Colors: green – working, red – not working, orange – break.\n'
                'Displays total hours worked and remaining for the day.',
          ),

          FAQItem(
            question: 'How to view the work schedule in real time?',
            answer:
            '• Schedule → shows employees with start, end, current status, and completed tasks.\n'
                '• Color codes: green – working, orange – break, red – vacation.\n'
                '• Use filters to find specific employees or tasks.',
          ),

          FAQItem(
            question: 'How to change an employee\'s working hours',
            answer:
            '• In the employee section, select an employee → work schedule → edit start/end times.\n'
                '• The system automatically updates the entire team\'s schedule and provides synchronization across all devices.\n'
                '• This feature is especially important for organizations with flexible work schedules.',
          ),

          FAQItem(
            question: 'How to see an employee\'s working hours last week',
            answer:
            '• In the employee section, select an employee → then a weekly report, after which each day, start/end, current status and completed tasks will open.\n'
                '• The system automatically calculates the total working hours for the week, allowing for high-quality analysis.',
          ),

          FAQItem(
            question: 'How to add vacation and break data?',
            answer:
            'Employees can request vacation via their personal profile.\n'
                'They specify start, end, and reason → request sent to manager.\n'
                'Manager approves/rejects → system updates work status automatically.\n'
                'During vacation, work tasks are unavailable unless authorized.',
          ),

          FAQItem(
            question: 'How to manage an employee\'s vacation',
            answer:
            '1. Vacations section → "Add new vacation".\n'
                '2. Specify the employee\'s name, start/end dates, reason (e.g. maternity leave, illness, personal).\n'
                '3. The system automatically updates the schedule, indicating color coding in the list: green, orange, red.\n'
                '• Vacation history is stored in the organization\'s historical data section up to one year ago.',
          ),

          // --- Раздел: Управление Задачами ---
          FAQHeader(title: 'Task controls'),

          FAQItem(
            question: 'How can I add and manage tasks?',
            answer:
            '• Go to Tasks → Add → Enter task name, start/end time, and responsible person.\n'
                '• The task automatically appears on the employee’s page.',
          ),

          FAQItem(
            question: 'How to add new tasks and assign a responsible employee?',
            answer:
            '1. Go to “Tasks” → “Add new task”.\n'
                '2. Specify task name, description, start/end times, and responsible employee.\n'
                '3. Task appears on employee’s page with progress indicator and deadlines.\n'
                'Example: “Weekly report check” 09:00–22:00, responsible: Gegham M.',
          ),

          FAQItem(
            question: 'How to create new tasks for employees?',
            answer:
            '1. Go to employee’s page → “Tasks” → “Add new task”.\n'
                '2. Enter task name, description, start/end times, responsible employee.\n'
                '3. Task appears in schedule with current status and notes.',
          ),

          FAQItem(
            question: 'How can I evaluate task progress?',
            answer:
            '• Go to “Tasks” → View current, completed, or postponed tasks.\n'
                '• Filter results by employee or task status.',
          ),

          FAQItem(
            question: 'How to track task performance?',
            answer:
            '• In Tasks section → choose employee → see current, completed, or delayed tasks.\n'
                '• Shows time spent for efficiency tracking.',
          ),

          FAQItem(
            question: 'How to monitor employee performance by tasks',
            answer:
            '• Tasks →  see the completion of each task, the time spent, the current status.\n'
                '• The system calculates the employee’s flexibility, work speed and even distribution.',
          ),

          FAQItem(
            question: 'How to track the real-time performance of employee tasks',
            answer:
            '• Tasks → → start/end times, current status and responsible person are displayed.\n'
                '• Using this tool, you can **simultaneously evaluate the work of all employees**.',
          ),

          FAQItem(
            question: 'How to view an employee’s completed tasks',
            answer:
            '• Employee page → “Tasks” → all current and completed tasks are displayed.\n'
                '• Start, end, end result, description, current status are displayed.\n'
                '• With this tool, managers can stay in touch and evaluate the quality of the team\'s work.',
          ),

          // --- Раздел: Документы и Коммуникация ---
          FAQHeader(title: 'Documents and communication'),

          FAQItem(
            question: 'How can I save documents?',
            answer:
            '• The system automatically saves all uploaded files using multi-layer encryption for data protection.',
          ),

          FAQItem(
            question: 'How can I search for documents?',
            answer:
            '• Go to Documents → Search → Specify the date, employee, or document type.',
          ),

          FAQItem(
            question: 'How can I manage different file types?',
            answer:
            '• Select the desired file format (PDF, DOCX, XLSX) → The system automatically recognizes and organizes them.',
          ),

          FAQItem(
            question: 'How to add a document and share it with the team?',
            answer:
            '1. Go to “Documents” → “Add new document”.\n'
                '2. Select file → specify type (contract, report, note).\n'
                '3. Choose employees or teams to share with.\n'
                '4. Click “Save” → shared automatically.\n'
                'Tip: Use description field for quick search.',
          ),

          FAQItem(
            question: 'How to see all documents by date or employee?',
            answer:
            '• In Documents section → “Search” → choose date or employee.\n'
                '• System lists all relevant files and who shared them.',
          ),

          FAQItem(
            question: 'How to receive notifications from an employee or team',
            answer:
            '• Notifications section → “New notification” → select employee or team, fill in the text, add a timestamp.\n'
                '• The selected employees receive the notification on their mobile and web pages, visible in real time.\n'
                '• For example: “Reminder: Team meeting at 3:00 PM.”',
          ),

          FAQItem(
            question: 'How to use the Notifications page for effective communication',
            answer:
            'The Notifications page in Poti is designed so that you can communicate with your team as quickly as possible and maintain order. Here you can:\n'
                '1. Click the “Notes” section.\n'
                '2. Click “Create new notification” → fill in the title and details.\n'
                '3. Select the recipient: a specific employee, the entire team or a department.\n'
                '4. Click “Send” → the notification is displayed in the mobile and web application, and employees see it in real time.',
          ),

          // --- Раздел: Планы и Оплата ---
          FAQHeader(title: 'Plans and Payment'),

          FAQItem(
            question: 'How can I switch from a free plan to a paid plan?',
            answer:
            '• Go to “Plan Management.”\n'
                '• Select the desired paid plan.\n'
                '• The system automatically sends a payment reminder 2 days in advance.',
          ),

          FAQItem(
            question: 'How can I modify my plan on a monthly basis?',
            answer:
            '• Choose a new plan → Pay by card → The system automatically updates your account.',
          ),

          FAQItem(
            question: 'How can I make a secure payment?',
            answer:
            '• Proceed to Payment → Enter your card details.\n'
                '• The system ensures the highest level of payment security — card information is not stored.',
          ),

          FAQItem(
            question: 'How can I receive a payment invoice and view all previous payments?',
            answer:
            'Once you make a payment, POT automatically generates an official payment invoice in PDF format, sent to your registered email.\n'
                'This report includes details — date, amount paid, selected plan, number of employees, and more.\n'
                'It ensures full financial transparency and reliability.',
          ),

          FAQItem(
            question: 'How can I receive payment reminders and manage payment deadlines?',
            answer:
            'POT automatically sends payment reminders two days before the due date.\n'
                'You will receive both an email and mobile notification.\n'
                'The system displays payment status — completed, scheduled, or overdue.\n'
                'If payment fails, access to certain features is restricted to maintain data security.',
          ),

          // --- Раздел: Аналитика и Общие Вопросы ---
          FAQHeader(title: 'Other questions'),

          FAQItem(
            question: 'How to view the overall efficiency of the team by month',
            answer:
            '• Graph → “Monthly Analysis” → the system displays the hours, completed tasks, vacations and breaks for each employee.\n'
                '• Use the graph to get a clear idea of who is working how efficiently and where improvements are needed.',
          ),

          FAQItem(
            question: 'How to check the presence and current status of an employee in real time',
            answer:
            '• Graph → select an employee → color coding shows whether they are working, on a break, on vacation or away.\n'
                '• This allows managers to monitor the team’s activities in real time.',
          ),

          FAQItem(
            question: 'How to use the mobile app for all functions',
            answer:
            '• The mobile application allows you to view tasks, documents, notifications, employee status and online reports.\n'
                '• You only need to log in with the same account, and the system automatically synchronizes data.',
          ),

          FAQItem(
            question: 'How to get additional help and support',
            answer:
            '• Poti has a help section: Frequently Asked Questions, live support, history of answers to sent questions.\n'
                '• You can also leave a review, whether it was useful or not, and get personalized tips that allow you to use the system quickly and effectively.',
          ),
        ],
      ),
    );
  }
}

// Вспомогательный виджет для заголовка раздела
class FAQHeader extends StatelessWidget {
  final String title;
  const FAQHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade700,
        ),
      ),
    );
  }
}

// Виджет для каждого отдельного вопроса/ответа
class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        key: PageStorageKey(widget.question),
        // Ключ для сохранения состояния
        title: Text(
          widget.question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.answer,
              style: const TextStyle(
                  color: Colors.black87, height: 1.4, fontSize: 14),
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        trailing: Icon(
          _isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}