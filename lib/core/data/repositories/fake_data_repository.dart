class FakeDataRepository {
  const FakeDataRepository();

  static const String studentName = 'Mahmoud Bakir';
  static const String studentId = '11360';

  Map<String, dynamic> getProfileOverview() {
    return const {
      'name': studentName,
      'studentId': studentId,
      'sessionSubtitle':
          '2025 - 2026 • Bachelor of Management Sciences – Semester 5',
    };
  }

  Map<String, dynamic> getHomeDashboard() {
    return {
      'studentName': studentName,
      'studentId': studentId,
      'attendancePercent': 75,
      'attendanceSubtitle':
          'Bachelor of Management Sciences – Semester 5 • Current term',
      'attendedClassesLabel': '8/11 lectures attended this week',
      'busRouteLabel': 'SAMS Shuttle 03 • Maadi → Ramses',
      'busStatusLabel': 'Status: Arriving at Gate 2 (Maadi Campus)',
      'announcements': getAnnouncements(),
    };
  }

  List<Map<String, dynamic>> getAnnouncements() {
    return const [
      {
        'title': 'SAMS Midterm Schedule (Semester 5) Published',
        'subtitle':
            'Please review your timetable on the SAMS portal. Any clash requests should be sent to Prof. Mohamed Salah before Wednesday 2:00 PM.',
        'badge': 'Important',
      },
      {
        'title': 'Tuition Installment Window – Spring 2026',
        'subtitle':
            'Student Affairs (Maadi Building A) will accept installment requests from 9:30 AM to 2:30 PM. Contact Dr. Fatima Ali for verification support.',
        'badge': 'Financial Aid',
      },
      {
        'title': 'Career Week: Banking & FMCG Talks',
        'subtitle':
            'Guest sessions start Sunday at the Main Auditorium. Opening talk moderated by Dr. Ahmed Hassan and Dr. Sara Ibrahim.',
        'badge': 'Academics',
      },
      {
        'title': 'Library Extended Hours Before Midterms',
        'subtitle':
            'SAMS Central Library will be open until 9:00 PM (Sun–Thu). Floor supervisors include Dr. Nourhan Adel and Prof. Karim Abdelrahman.',
        'badge': 'Campus',
      },
    ];
  }

  Map<String, dynamic> getAttendanceOverview() {
    return {'overallPercent': 75, 'subjects': getAttendanceSubjects()};
  }

  List<Map<String, dynamic>> getAttendanceSubjects() {
    return const [
      {'subject': 'Accounting Principles • Dr. Ahmed Hassan', 'percentage': 90},
      {'subject': 'Business Administration • Dr. Fatima Ali', 'percentage': 86},
      {
        'subject': 'Marketing Management • Prof. Mohamed Salah',
        'percentage': 81,
      },
      {'subject': 'Financial Management • Dr. Sara Ibrahim', 'percentage': 77},
      {
        'subject': 'Human Resources Management • Dr. Youssef Mahmoud',
        'percentage': 69,
      },
      {
        'subject': 'Management Information Systems • Dr. Nourhan Adel',
        'percentage': 63,
      },
      {
        'subject': 'Economics for Managers • Prof. Karim Abdelrahman',
        'percentage': 58,
      },
      {'subject': 'Business Statistics • Dr. Mariam Mostafa', 'percentage': 44},
    ];
  }

  List<Map<String, dynamic>> getMessageThreads() {
    return const [
      {
        'name': 'Dr. Ahmed Hassan',
        'message':
            'Reminder: Accounting quiz starts 10:00 AM sharp in Hall M203. Bring your SAMS ID card.',
      },
      {
        'name': 'Dr. Sara Ibrahim',
        'message':
            'Financial Management case study rubric is now available on Moodle.',
      },
      {
        'name': 'Prof. Mohamed Salah (Class Advisor)',
        'message':
            'Attendance for Monday lecture will be taken in the first 15 minutes only.',
      },
      {
        'name': 'Dr. Mariam Mostafa - Student Affairs',
        'message':
            'Your internship letter is ready for collection from Building B counter 4.',
      },
      {
        'name': 'Dr. Nourhan Adel',
        'message': 'MIS lab section has moved to Computer Lab 2 this Tuesday.',
      },
      {
        'name': 'Prof. Karim Abdelrahman',
        'message':
            'Economics discussion section will focus on Egypt inflation trends for 2025.',
      },
    ];
  }

  List<Map<String, dynamic>> getComplaints() {
    return const [
      {
        'department': 'Transport Department',
        'message':
            'I moved from Maadi to Nasr City. Please change my shuttle route from Line 03 to Line 06 starting next week.',
        'contact': 'Mr. Hany Nabil\nTransport Office – Gate 1',
      },
      {
        'department': 'IT Support',
        'message':
            'SAMS portal login keeps timing out on campus Wi-Fi between 8:00 PM and 10:00 PM in Building C.',
        'contact': 'helpdesk.it@sams.edu.eg\nExt. 214',
      },
      {
        'department': 'Library Services',
        'message':
            'My student card is active for borrowing books but not for accessing EBSCO databases from the digital library lab.',
        'contact': 'library.support@sams.edu.eg\nExt. 118',
      },
    ];
  }

  Map<String, dynamic> getBusSnapshot() {
    return const {
      'currentStatus': 'In Campus',
      'currentStop': 'Maadi Campus (SAMS)',
    };
  }

  List<Map<String, dynamic>> getBusRouteStops() {
    return const [
      {'stop': 'Maadi Corniche', 'time': '7:35 AM', 'status': 'Origin'},
      {'stop': 'Tahrir Square', 'time': '8:00 AM', 'status': 'Passed'},
      {'stop': 'Giza Square', 'time': '8:18 AM', 'status': 'Passed'},
      {'stop': 'Cairo University', 'time': '8:32 AM', 'status': 'Current'},
      {'stop': 'Ramses Station', 'time': '8:52 AM', 'status': 'Upcoming'},
      {'stop': 'Helwan', 'time': '9:18 AM', 'status': 'Upcoming'},
    ];
  }

  Map<String, dynamic> getBusLiveInfo() {
    return const {
      'nextStop': 'Ramses Station',
      'eta': '12 mins',
      'lastUpdated': 'Updated 2 mins ago',
      'routeSummary': 'Morning Shuttle • 6 major stops • 33km • 1 hour 40 mins',
    };
  }

  List<Map<String, dynamic>> getHostelMenuItems() {
    return const [
      {
        'title': 'Leave Permission',
        'subtitle': 'Request weekend leave and in/out movement approvals',
      },
      {
        'title': 'Fee Receipt',
        'subtitle': 'View and download tuition and hostel payment receipts',
      },
      {
        'title': 'Mess Feedback',
        'subtitle': 'Submit daily meal quality, variety, and hygiene feedback',
      },
      {
        'title': 'Maintenance Request',
        'subtitle': 'Report AC, plumbing, electrical, or furniture issues',
      },
    ];
  }

  List<Map<String, dynamic>> getScanOptions() {
    return const [
      {'label': 'Scan SAMS ID from gallery'},
      {'label': 'Scan SAMS ID with camera'},
    ];
  }
}
