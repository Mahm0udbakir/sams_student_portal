class FakeDataRepository {
  const FakeDataRepository();

  static const String studentName = 'Mahmoud Bakir';
  static const String studentId = '11360';

  Map<String, dynamic> getProfileOverview() {
    return const {
      'name': studentName,
      'studentId': studentId,
      'sessionSubtitle': '2025 - 2026 • B.Des Semester 5',
    };
  }

  Map<String, dynamic> getHomeDashboard() {
    return {
      'studentName': studentName,
      'studentId': studentId,
      'attendancePercent': 75,
      'attendanceSubtitle': 'B.Des Semester 5 • Current term',
      'attendedClassesLabel': '8/11 classes attended',
      'busRouteLabel': 'Route 03 • North Loop',
      'busStatusLabel': 'Status: Arriving at Main Gate',
      'announcements': getAnnouncements(),
    };
  }

  List<Map<String, dynamic>> getAnnouncements() {
    return const [
      {
        'title': 'Application Open for DEBSOC Core Team 2025',
        'subtitle':
            'Last date to apply is Sept 18. Interviews start from Sept 22 in Block B Seminar Hall.',
        'badge': 'Important',
      },
      {
        'title': 'Post Matric Scholarship Verification Window',
        'subtitle':
            'Document verification desk will remain open from 10:00 AM to 4:00 PM through Sept 12 at Block A Reception.',
        'badge': 'Financial Aid',
      },
      {
        'title': 'Mid-Semester Examination Schedule Released',
        'subtitle':
            'Please check your exam timetable on ERP and report conflicts to the exam cell within 48 hours.',
        'badge': 'Academics',
      },
      {
        'title': 'Hostel Night Entry Advisory',
        'subtitle':
            'Late entry after 9:30 PM requires prior approval from hostel office and wardens.',
        'badge': 'Hostel',
      },
    ];
  }

  Map<String, dynamic> getAttendanceOverview() {
    return {
      'overallPercent': 75,
      'subjects': getAttendanceSubjects(),
    };
  }

  List<Map<String, dynamic>> getAttendanceSubjects() {
    return const [
      {'subject': 'Business Analytics', 'percentage': 92},
      {'subject': 'Marketing Management', 'percentage': 84},
      {'subject': 'Financial Accounting', 'percentage': 78},
      {'subject': 'Operations Research', 'percentage': 74},
      {'subject': 'Organizational Behavior', 'percentage': 65},
      {'subject': 'Business Law', 'percentage': 59},
      {'subject': 'Managerial Economics', 'percentage': 52},
      {'subject': 'Quantitative Techniques', 'percentage': 38},
    ];
  }

  List<Map<String, dynamic>> getMessageThreads() {
    return const [
      {
        'name': 'Gopal Meena',
        'message': 'Sure, let\'s review the studio brief tomorrow at 10:30 AM.',
      },
      {
        'name': 'Mandeep Kaur',
        'message': 'Thanks! I uploaded the typography assignment files.',
      },
      {
        'name': 'Class Rep - B.Des',
        'message': 'Attendance notice shared for tomorrow. Bring your ID cards.',
      },
      {
        'name': 'Placement Cell',
        'message':
            'Portfolio review slot confirmed for Friday at 11:30 AM in Studio Lab 2.',
      },
    ];
  }

  List<Map<String, dynamic>> getComplaints() {
    return const [
      {
        'department': 'Transport Department',
        'message':
            'I need to change my route number as I have shifted my house from sector 22 to sector 15 Chandigarh.',
        'contact': 'Mr. Harsh\nCell C',
      },
      {
        'department': 'IT Support',
        'message':
            'Student portal takes too long to load on hostel Wi-Fi during evening hours.',
        'contact': 'helpdesk.it@sams.edu\nExt. 214',
      },
      {
        'department': 'Library Services',
        'message':
            'My library card is not unlocking the digital journal portal from campus lab systems.',
        'contact': 'library.support@sams.edu\nExt. 118',
      },
    ];
  }

  Map<String, dynamic> getBusSnapshot() {
    return const {
      'currentStatus': 'In Campus',
      'currentStop': 'SAMS University',
    };
  }

  List<Map<String, dynamic>> getBusRouteStops() {
    return const [
      {'stop': 'SAMS University', 'time': '9:15 AM', 'status': 'Current'},
      {'stop': 'Zirakpur Lights', 'time': '8:45 AM', 'status': 'Passed'},
      {'stop': 'Elante Lights', 'time': '8:30 AM', 'status': 'Passed'},
      {'stop': 'Sector 17 Plaza', 'time': '8:26 AM', 'status': 'Upcoming'},
      {'stop': 'Sector 28', 'time': '8:20 AM', 'status': 'Origin'},
    ];
  }

  Map<String, dynamic> getBusLiveInfo() {
    return const {
      'nextStop': 'Sector 17 Plaza',
      'eta': '12 mins',
      'lastUpdated': 'Updated 2 mins ago',
      'routeSummary': '12 stops • 29km • 1 hour 16 mins',
    };
  }

  List<Map<String, dynamic>> getHostelMenuItems() {
    return const [
      {
        'title': 'Gate pass',
        'subtitle': 'Gate pass for Student Leave, In & Out Campus Requests',
      },
      {
        'title': 'Payment Receipt',
        'subtitle': 'Payment Transaction Receipt',
      },
      {
        'title': 'Mess Feedback',
        'subtitle': 'Submit daily meal quality and hygiene feedback',
      },
      {
        'title': 'Room Maintenance',
        'subtitle': 'Raise plumbing, electrical, or furniture maintenance requests',
      },
    ];
  }

  List<Map<String, dynamic>> getScanOptions() {
    return const [
      {'label': 'Choose from gallery'},
      {'label': 'Take a photo'},
    ];
  }
}