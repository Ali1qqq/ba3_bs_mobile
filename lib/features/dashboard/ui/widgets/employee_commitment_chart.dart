import 'package:ba3_bs_mobile/features/dashboard/ui/widgets/employee_date_month_header.dart';
import 'package:flutter/material.dart';

class EmployeeCommitmentChart extends StatelessWidget {
  final List<Employee> employees;

  const EmployeeCommitmentChart({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmployeeDateMonthHeader(),
        Container(
            color: Colors.white,
            height: 800,
            child: ListView.builder(itemBuilder: (context, index) => buildEmployeeCard(employees[index]), itemCount: employees.length))
      ],
    );
  }
}

class Employee {
  final String name;
  final double accessoriesTarget; // out of 100%
  final double mobilesTarget; // out of 100%
  final int absentDays;
  final int lateDays;
  final double taskCompletion; // out of 100%

  Employee({
    required this.name,
    required this.accessoriesTarget,
    required this.mobilesTarget,
    required this.absentDays,
    required this.lateDays,
    required this.taskCompletion,
  });

  // double get attendanceScore {
  //   double score = 25;
  //   score -= absentDays * 5;
  //   score -= lateDays * 2;
  //   return score.clamp(0, 25);
  // }

  double get accessoriesScore => ((accessoriesTarget / 75000) * 25).clamp(0, 25);

  double get mobilesScore => ((mobilesTarget / 150000) * 25).clamp(0, 25);

  double get taskScore => (taskCompletion / 100 * 25).clamp(0, 25);

  double get attendanceScore => ((absentDays / 30) * 25).clamp(0, 25);

  double get totalCommitment => accessoriesScore + mobilesScore + attendanceScore + taskScore;
}

Widget buildEmployeeCard(Employee employee) {
  return Card(
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(employee.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Accessories: ${employee.accessoriesScore.toStringAsFixed(1)} / 25"),
          Text("Mobiles: ${employee.mobilesScore.toStringAsFixed(1)} / 25"),
          Text("Attendance: ${employee.attendanceScore.toStringAsFixed(1)} / 25"),
          Text("Tasks: ${employee.taskScore.toStringAsFixed(1)} / 25"),
          Divider(),
          Text("Total Commitment: ${employee.totalCommitment.toStringAsFixed(1)} / 100", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}