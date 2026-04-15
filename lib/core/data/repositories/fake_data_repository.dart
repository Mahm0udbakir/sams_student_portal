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

  List<Map<String, dynamic>> getCalendarSchedule({
    required int year,
    required int month,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int safeDay(int day) => day.clamp(1, daysInMonth);

    final items = <Map<String, dynamic>>[];

    void addItem({
      required int day,
      required String type,
      required String title,
      required String timeRange,
      required String location,
      String? note,
    }) {
      items.add({
        'day': safeDay(day),
        'type': type,
        'title': title,
        'timeRange': timeRange,
        'location': location,
        if (note != null) 'note': note,
      });
    }

    // Core weekly lecture rhythm (Sun/Tue/Thu) similar to Egyptian university schedules.
    addItem(
      day: 3 + (month % 3),
      type: 'lecture',
      title: 'Accounting Principles Lecture',
      timeRange: '09:00 AM - 10:30 AM',
      location: 'Lecture Hall B2',
      note: 'Dr. Ahmed Hassan',
    );
    addItem(
      day: 8 + (month % 4),
      type: 'lecture',
      title: 'Financial Management Tutorial',
      timeRange: '11:00 AM - 12:30 PM',
      location: 'Room C-114',
      note: 'Dr. Sara Ibrahim',
    );
    addItem(
      day: 16 + (month % 5),
      type: 'lecture',
      title: 'MIS Lab Session',
      timeRange: '01:30 PM - 03:00 PM',
      location: 'Computer Lab 2',
      note: 'Dr. Nourhan Adel',
    );

    // Mid-month activity/event.
    addItem(
      day: 11 + (month % 6),
      type: 'event',
      title: 'Student Activities Committee Meetup',
      timeRange: '12:30 PM - 02:00 PM',
      location: 'Student Union Hall',
      note: 'Open for all Semester 5 students',
    );

    // Periodic assessments.
    addItem(
      day: 20 + (month % 4),
      type: 'exam',
      title: month == 1 || month == 6
          ? 'Final Exam - Business Administration'
          : 'Quiz - Operations Management',
      timeRange: month == 1 || month == 6
          ? '10:00 AM - 12:00 PM'
          : '09:30 AM - 10:30 AM',
      location: month == 1 || month == 6 ? 'Main Exam Hall A' : 'Hall M-203',
      note: 'Bring SAMS ID and approved calculator',
    );

    // Birthdays and social events (human touch similar to your reference).
    addItem(
      day: 7 + (month % 7),
      type: 'birthday',
      title: 'Gana Abdelrahman Birthday',
      timeRange: 'After lectures',
      location: 'Campus Café Terrace',
      note: 'Classmates gathering',
    );

    // Egyptian academic-season highlights.
    switch (month) {
      case 2:
        addItem(
          day: 15,
          type: 'event',
          title: 'Spring Semester Orientation',
          timeRange: '10:00 AM - 12:00 PM',
          location: 'SAMS Main Auditorium',
          note: 'Dean office + Student Affairs',
        );
        break;
      case 3:
        addItem(
          day: 8,
          type: 'event',
          title: 'Career Week: Banking Track',
          timeRange: '01:00 PM - 03:30 PM',
          location: 'Conference Hall, Building A',
          note: 'Hosted with Banque Misr alumni',
        );
        break;
      case 4:
        addItem(
          day: 24,
          type: 'exam',
          title: 'Midterm Exam - Marketing Management',
          timeRange: '09:00 AM - 11:00 AM',
          location: 'Exam Hall C',
          note: 'Semester 5 core requirement',
        );
        break;
      case 5:
        addItem(
          day: 5,
          type: 'event',
          title: 'Community Service Day (Maadi)',
          timeRange: '09:30 AM - 01:00 PM',
          location: 'Maadi Community Center',
          note: 'Volunteer hours count toward activities record',
        );
        break;
      case 9:
        addItem(
          day: 28,
          type: 'event',
          title: 'Fall Semester Kickoff',
          timeRange: '11:00 AM - 01:00 PM',
          location: 'Open Air Theater',
          note: 'Welcome session for returning students',
        );
        break;
      case 10:
        addItem(
          day: 6,
          type: 'event',
          title: 'October Victory Commemoration Talk',
          timeRange: '12:00 PM - 01:00 PM',
          location: 'History Hall, Building D',
          note: 'Special lecture by Dr. Khaled Samir',
        );
        break;
      case 11:
        addItem(
          day: 19,
          type: 'exam',
          title: 'Midterm Exam - Economics for Managers',
          timeRange: '11:30 AM - 01:30 PM',
          location: 'Exam Hall B',
          note: 'Paper-based exam',
        );
        break;
      case 12:
        addItem(
          day: 14,
          type: 'birthday',
          title: 'Class Advisor Birthday - Prof. Mohamed Salah',
          timeRange: '02:30 PM - 03:00 PM',
          location: 'Faculty Lounge',
          note: 'Short appreciation gathering',
        );
        break;
    }

    items.sort((a, b) {
      final dayCompare = (a['day'] as int).compareTo(b['day'] as int);
      if (dayCompare != 0) {
        return dayCompare;
      }

      const typeOrder = {'exam': 0, 'lecture': 1, 'event': 2, 'birthday': 3};
      return (typeOrder[a['type'] as String] ?? 9).compareTo(
        typeOrder[b['type'] as String] ?? 9,
      );
    });

    return items;
  }

  List<Map<String, dynamic>> getScanOptions() {
    return const [
      {'label': 'Scan SAMS ID from gallery'},
      {'label': 'Scan SAMS ID with camera'},
    ];
  }
}
