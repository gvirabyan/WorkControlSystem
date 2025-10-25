import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'FAQ',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

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
            question: 'How can I recover a forgotten password?',
            answer:
            '• Click the “Forgot Password” button.\n'
                '• Enter your registered email address.\n'
                '• The system will send you a recovery link with a temporary password.\n'
                '• Log in and set a new password.',
          ),

          FAQItem(
            question: 'What is a promo code, and why is it needed?',
            answer:
            '• A promo code uniquely links an employee to their organization.\n'
                '• For example, the code 64-42-41 automatically assigns an employee to the corresponding organization’s list.\n'
                '• This ensures managed, secure, and fast access to the system.',
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
            question: 'How can I receive a payment invoice?',
            answer:
            '• After completing the payment, a PDF invoice is automatically sent to your email.',
          ),

          FAQItem(
            question: 'How can I receive payment reminders?',
            answer:
            '• The system automatically sends a reminder two days before the payment due date.',
          ),

          FAQItem(
            question: 'How can I add new employees?',
            answer:
            '• Go to the Organization Page → Add Employee.\n'
                '• Enter the employee’s name, email address, and promo code.\n'
                '• The employee is automatically added to the organization list.',
          ),

          FAQItem(
            question: 'How can I edit employee details?',
            answer:
            '• Click on the employee’s name → Edit → Save.',
          ),

          FAQItem(
            question: 'How can I view working hours and current status?',
            answer:
            '• Go to Schedule Section → Designated Fields.\n'
                ' ◦ Green – Working\n ◦ Red – Not working\n ◦ Orange – On break',
          ),

          FAQItem(
            question: 'How can I add and manage tasks?',
            answer:
            '• Go to Tasks → Add → Enter task name, start/end time, and responsible person.\n'
                '• The task automatically appears on the employee’s page.',
          ),

          FAQItem(
            question: 'How can I evaluate task progress?',
            answer:
            '• Go to “Tasks” → View current, completed, or postponed tasks.\n'
                '• Filter results by employee or task status.',
          ),

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

          FAQItem(
            question: 'How to add a new employee and link them to the organization with a promo code?',
            answer:
            'When registering in POT, the employee enters the organization’s promo code, linking their account to your organization.\n'
                'Go to “Employees” → “Add employee” → Fill in first name, last name, email, and status.\n'
                'The employee appears in the organization’s list with task and schedule tracking.',
          ),

          FAQItem(
            question: 'How to edit an employee’s personal data and work status?',
            answer:
            'Click on the employee’s name → “Edit data” → Change fields (email, phone, hours, tasks).\n'
                'Change status: “Working”, “Break”, “Vacation”.\n'
                'System automatically updates schedule with colors: green – working, orange – break, red – away.',
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
            question: 'How to track an employee’s working hours and current status?',
            answer:
            'Select the employee in the graphic section → View start, end, and current status.\n'
                'Colors: green – working, red – not working, orange – break.\n'
                'Displays total hours worked and remaining for the day.',
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
            question: 'How to remove an employee or suspend their access?',
            answer:
            'Click on employee’s name → “Remove employee” → Confirm.\n'
                'System encrypts their data and removes them from the list.',
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
            question: 'How to create new tasks for employees?',
            answer:
            '1. Go to employee’s page → “Tasks” → “Add new task”.\n'
                '2. Enter task name, description, start/end times, responsible employee.\n'
                '3. Task appears in schedule with current status and notes.',
          ),

          FAQItem(
            question: 'How to track task performance?',
            answer:
            '• In Tasks section → choose employee → see current, completed, or delayed tasks.\n'
                '• Shows time spent for efficiency tracking.',
          ),

          FAQItem(
            question: 'How to view the work schedule in real time?',
            answer:
            '• Schedule → shows employees with start, end, current status, and completed tasks.\n'
                '• Color codes: green – working, orange – break, red – vacation.\n'
                '• Use filters to find specific employees or tasks.',
          ),

          FAQItem(
            question: 'How to add a new employee in real time?',
            answer:
            '1. Organization page → “Add employee”.\n'
                '2. Enter first name, last name, email, password, and promo code.\n'
                '3. Employee is instantly linked; schedule updates in real time.',
          ),
        ],
      ),
    );
  }
}

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
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          Text(
            widget.answer,
            style: const TextStyle(color: Colors.black87, height: 1.4),
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
