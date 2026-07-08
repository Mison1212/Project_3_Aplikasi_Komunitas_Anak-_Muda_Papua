class Job {
  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.category,
    required this.description,
    required this.requirements,
    required this.deadline,
    this.salary = '',
  });

  final int id;
  final String title;
  final String company;
  final String location;
  final String category;
  final String description;
  final String requirements;
  final String deadline;
  final String salary;

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: int.tryParse('${json['id']}') ?? 0,
      title: '${json['title'] ?? ''}',
      company: '${json['company'] ?? ''}',
      location: '${json['location'] ?? ''}',
      category: '${json['category'] ?? ''}',
      description: '${json['description'] ?? ''}',
      requirements: '${json['requirements'] ?? ''}',
      deadline: '${json['deadline'] ?? ''}',
      salary: '${json['salary'] ?? json['gaji'] ?? ''}',
    );
  }
}
