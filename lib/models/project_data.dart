import 'project.dart';

// ════════════════════════════════════════════════════════════════
//  PROJECT DATA — EDIT THIS FILE TO ADD / UPDATE YOUR PROJECTS
// ════════════════════════════════════════════════════════════════
//
//  HOW TO ADD A NEW PROJECT:
//  1. Copy one of the Project(...) blocks below
//  2. Give it a unique 'id' (used in the URL: /work/<id>)
//  3. Fill in title, description, techStack, githubUrl, etc.
//  4. Add screenshots to assets/images/projects/ and list them
//     in 'screenshotPaths' and update pubspec.yaml
//  5. Add the Project to the 'projectList' list
//
//  HOW TO REMOVE A PROJECT:
//  - Delete or comment out the Project(...) block
//
// ════════════════════════════════════════════════════════════════

/// All portfolio projects — displayed in the order listed here.
final List<Project> projectList = [
  // ── PROJECT 1 ─────────────────────────────────────────────
  const Project(
    id: 'social-media-app',
    title: 'Sanctuary',
tagline: 'A modern social media platform for meaningful connections',

description:
    'A full-stack social media application where users can connect, '
    'share posts, interact with others, and build communities in a '
    'secure and engaging environment.',

techStack: [
  'FLUTTER',
  'DART',
  'NODE.JS',
  'EXPRESS.JS',
  'MONGODB',
  'SOCKET.IO',
  'JWT',
  'CLOUDINARY'
],

githubUrl: 'https://github.com/Supratim158/Sanctuary-socialmedia-user-app.git',
liveUrl: '',
imagePath: 'assets/project/sanctuary.png',

longDescription:
    'Sanctuary is a cross-platform social media application built with '
    'Flutter and a Node.js backend, designed to provide a smooth and '
    'interactive social networking experience. Users can create accounts, '
    'share posts with images, like and comment on content, follow other '
    'users, and manage personalized profiles.\n\n'
    'The application uses JWT-based authentication for secure access, '
    'MongoDB for data storage, Cloudinary for media management, and '
    'Socket.IO for real-time interactions such as notifications and live '
    'updates. The app follows a scalable RESTful architecture with a '
    'clean, responsive UI optimized for Android, iOS, and Web.',

features: [
  'Secure JWT authentication and user profiles',
  'Create, edit, and delete posts with image uploads',
  'Like, comment, and share functionality',
  'Follow and unfollow users',
  'Real-time notifications using Socket.IO',
  'Cloudinary integration for media storage',
  'Personalized news feed',
  'Search users and posts',
  'Responsive Flutter UI with smooth animations',
  'RESTful backend with MongoDB integration',
],

role: 'Full Stack Developer',
duration: '3 months',
    status: 'In Progress',
  ),
  // ── PROJECT 6 ─────────────────────────────────────────────
  const Project(
    id: 'offline-survival-companion',
    title: 'Offline Survival Companion',
tagline: 'Offline-first emergency companion for survival, navigation, and disaster preparedness',

description:
    'A comprehensive offline survival application designed to provide '
    'essential emergency resources, navigation tools, and survival guides '
    'without requiring an internet connection.',

techStack: [
  'FLUTTER',
  'DART',
  'FIREBASE',
  'GOOGLE MAPS',
  'SQFLITE',
  'SHARED PREFERENCES',
],

githubUrl: 'https://github.com/Supratim158/Offline-Survival-Companion',
liveUrl: '',
imagePath: 'assets/project/women.png',

longDescription:
    'Offline Survival Companion is a mobile application built to assist users '
    'during emergencies, natural disasters, and outdoor adventures by providing '
    'critical survival information entirely offline. The application combines '
    'interactive tools, emergency resources, and location-based utilities into '
    'a single, easy-to-use platform.\n\n'
    'Designed with reliability in mind, the app stores essential data locally, '
    'allowing users to access survival guides, emergency contacts, first-aid '
    'information, and navigation support even when internet connectivity is '
    'unavailable. The intuitive Flutter interface ensures a smooth experience '
    'across Android devices while maintaining fast offline performance.',

features: [
  'Offline survival guides and emergency resources',
  'First-aid and disaster preparedness information',
  'Emergency contacts management',
  'Offline location and navigation utilities',
  'Interactive survival checklists',
  'Local data storage for internet-free access',
  'Responsive Flutter UI optimized for mobile devices',
  'Lightweight and reliable offline architecture',
],

role: 'Flutter Developer',
duration: '2 months',
status: 'In Progress',
  ),

  // ── PROJECT 2 ─────────────────────────────────────────────
  const Project(
    id: 'projexhub-v2',
    title: 'ProjexHub V2',
    tagline: 'Project showcasing platform for students and developers',
    description:
        'A full-stack platform where students and developers can showcase '
        'their projects, research papers, and technical achievements with '
        'an admin approval workflow.',

    techStack: [
      'FLUTTER',
      'NODE.JS',
      'EXPRESS.JS',
      'MONGODB',
      'JWT',
      'CLOUDINARY'
    ],

    githubUrl: 'https://github.com/Supratim158/projexhub_v2_userapp.git',
    liveUrl: '',
    imagePath: 'assets/project/px2.png',

    longDescription:
        'ProjexHub V2 is a full-stack project showcasing platform designed '
        'to help students, developers, and researchers publish and manage '
        'their technical projects in one place. Users can create detailed '
        'project listings with images, videos, reports, presentations, '
        'GitHub repositories, and live demo links.\n\n'
        'The platform features a secure authentication system, role-based '
        'access control, and an admin dashboard for reviewing, approving, '
        'or rejecting submitted projects. Media files are stored using '
        'Cloudinary, while project information is managed with MongoDB. '
        'The application follows a clean, responsive UI built with Flutter '
        'and a RESTful backend developed using Node.js and Express.',

    features: [
      'Secure JWT authentication and user management',
      'Project submission with images, videos, PDFs, and GitHub links',
      'Admin dashboard for approving or rejecting projects',
      'Role-based access control for users and administrators',
      'Cloudinary integration for media storage',
      'Search and filter projects by technology and category',
      'Responsive Flutter UI for Android, iOS, and Web',
      'RESTful API with MongoDB database integration',
      'Real-time project status updates',
      'Technology-wise project categorization',
      'Profile management for users',
    ],

    role: 'Full Stack Developer',
    duration: '3 months',
    status: 'Completed',
  ),

  // ── PROJECT 3 ─────────────────────────────────────────────
  const Project(
    id: 'personal-ai',
    title: 'TYSON Personal AI',
    tagline: 'Desktop AI assistant for voice interaction and task automation',
    imagePath: 'assets/project/ai.png',
    description:
        'An AI-powered desktop assistant that performs voice-controlled tasks, '
        'answers queries, automates daily operations, and provides an interactive '
        'chat experience through a simple desktop interface.',

    techStack: [
      'PYTHON',
      'FLASK',
      'EEL',
      'HTML',
      'CSS',
      'JAVASCRIPT',
      'HUGGINGFACE API',
    ],

    githubUrl: 'https://github.com/Supratim158/TYSON_Personal_Ai',
    liveUrl: '',
    

    longDescription:
        'TYSON Personal AI is a desktop-based virtual assistant developed using '
        'Python and Eel, combining the power of AI with an intuitive web-based '
        'interface. The application enables users to interact using voice or text, '
        'execute everyday tasks, retrieve information, and receive intelligent '
        'responses through an integrated large language model.\n\n'
        'The frontend is built using HTML, CSS, and JavaScript, while the backend '
        'leverages Flask and Python to manage application logic and AI integration. '
        'TYSON is designed with a modular architecture, making it easy to extend '
        'with new commands, automation features, and third-party service '
        'integrations.',

    features: [
      'Voice-based command recognition',
      'AI-powered conversational assistant',
      'Desktop application using Eel',
      'Natural language query processing',
      'Task automation and utility commands',
      'Modern responsive user interface',
      'Flask-powered backend architecture',
      'Modular design for adding new AI capabilities',
    ],

    role: 'Full Stack Developer',
    duration: '2 months',
    status: 'Completed',
  ),

  // ── PROJECT 4 ─────────────────────────────────────────────
  const Project(
    id: 'swasth-ai',
    title: 'Swasth AI',
tagline: 'AI-powered healthcare platform for intelligent diagnosis and patient management',

description:
    'A full-stack healthcare platform that leverages artificial intelligence '
    'to provide skin disease detection, health assessments, patient record '
    'management, and an intelligent medical assistant.',

techStack: [
  'NEXT.JS',
  'REACT',
  'TAILWIND CSS',
  'TYPESCRIPT',
  'FASTAPI',
  'PYTHON',
  'SCIKIT-LEARN',
  'GRADIO',
  'DOCKER',
],

githubUrl: 'https://github.com/Supratim158/SwasthAI.git',
liveUrl: 'https://swasth-ai-five.vercel.app/',
imagePath: 'assets/project/swai.png',

longDescription:
    'Swasth AI is an AI-powered healthcare platform designed to assist users '
    'with preliminary health analysis through machine learning and an intuitive '
    'web interface. The platform combines modern frontend technologies with a '
    'FastAPI backend to deliver intelligent diagnostic tools, patient record '
    'management, and interactive health assessments.\n\n'
    'The system includes AI-based skin disease analysis, a conversational '
    'health assistant, secure patient record management, and real-time data '
    'visualization dashboards. Built with scalability in mind, Swasth AI '
    'follows a modular architecture and is containerized using Docker for '
    'simplified deployment.',

features: [
  'AI-powered skin disease detection',
  'Interactive health assessment system',
  'Intelligent AI health assistant',
  'Secure patient records management',
  'Real-time health analytics and dashboards',
  'Interactive charts using Recharts and Plotly',
  'FastAPI RESTful backend',
  'Responsive Next.js frontend with Tailwind CSS',
  'Dockerized deployment for easy scalability',
],

role: 'Frontend Developer',
duration: '1 months',
status: 'Completed',
  ),

  // ── PROJECT 5 ─────────────────────────────────────────────
  const Project(
    id: 'monitor',
    title: 'Smart Classroom Monitoring',
tagline: 'AI-powered classroom monitoring and attendance management system',

description:
    'An intelligent classroom monitoring platform that leverages computer '
    'vision and deep learning to automate attendance, monitor classroom '
    'activities, and provide real-time analytics for educators.',

techStack: [
  'PYTHON',
  'FLASK',
  'OPENCV',
  'YOLOv8',
  'TENSORFLOW',
  'FACE RECOGNITION',
  'HTML',
  'CSS',
  'JAVASCRIPT',
],

githubUrl: 'https://github.com/Supratim158/Smart-Classroom-Monitoring',
liveUrl: '',
imagePath: 'assets/project/smart.png',

longDescription:
    'Smart Classroom Monitoring is an AI-driven classroom management system '
    'designed to improve the efficiency of attendance tracking and classroom '
    'supervision. Using computer vision and deep learning, the platform '
    'automatically detects and recognizes students, monitors classroom '
    'activities, and generates real-time insights for teachers.\n\n'
    'The system integrates face recognition with YOLO-based object detection '
    'to identify students and analyze classroom interactions. Built with a '
    'Flask backend and a responsive web interface, it provides an intuitive '
    'dashboard for monitoring attendance, viewing analytics, and managing '
    'student records while reducing manual effort and improving accuracy.',

features: [
  'Automated attendance using face recognition',
  'Real-time student detection with YOLOv8',
  'AI-powered classroom activity monitoring',
  'Attendance history and student record management',
  'Interactive dashboard with classroom analytics',
  'Image and video processing using OpenCV',
  'Responsive web interface for teachers',
  'Flask-based backend with scalable architecture',
],

role: 'AI & Full Stack Developer',
duration: '1 months',
status: 'Completed',
  ),

  // ── PROJECT 6 ─────────────────────────────────────────────
  const Project(
    id: 'projexhub-v1',
    title: 'ProjexHub V1',
tagline: 'Project sharing platform for students and developers',

description:
    'A Flutter and Firebase-based platform that enables students and '
    'developers to showcase their projects, research papers, and technical '
    'achievements through a modern and intuitive interface.',

techStack: [
  'FLUTTER',
  'DART',
  'FIREBASE AUTH',
  'CLOUD FIRESTORE',
  'FIREBASE STORAGE',
],

githubUrl: 'https://github.com/Supratim158/Projex-hub.git',
liveUrl: '',
imagePath: 'assets/project/px1.png',

longDescription:
    'ProjexHub V1 is the first version of a project showcasing platform '
    'built with Flutter and Firebase. It allows users to securely sign in, '
    'upload project details, attach images and documentation, and explore '
    'projects shared by other developers. The application was designed to '
    'promote collaboration and provide a centralized space for students to '
    'present their technical work.\n\n'
    'Firebase Authentication handles secure user login, Cloud Firestore '
    'stores project information, and Firebase Storage manages media files. '
    'The app features a clean and responsive interface optimized for Android, '
    'with a scalable architecture that later evolved into ProjexHub V2 using '
    'a dedicated Node.js backend and MongoDB.',

features: [
  'Firebase Authentication for secure login',
  'Create, edit, and manage project submissions',
  'Upload project images and documents',
  'Cloud Firestore for real-time data storage',
  'Firebase Storage integration for media files',
  'Browse and discover community projects',
  'Responsive Flutter UI with Material Design',
  'Real-time project updates using Firestore',
],

role: 'Flutter Developer',
duration: '6 months',
status: 'Completed',
  ),
  // ── PROJECT 7 ─────────────────────────────────────────────
  const Project(
    id: 'face-auth',
    title: 'Face Authentication Attendance System',
tagline: 'AI-powered facial recognition system for secure attendance management',

description:
    'An intelligent attendance management system that uses facial recognition '
    'to automate attendance marking, eliminate manual records, and improve '
    'accuracy through real-time face authentication.',

techStack: [
  'PYTHON',
  'OPENCV',
  'FACE RECOGNITION',
  'NUMPY',
  'PANDAS',
  'TKINTER',
],

githubUrl: 'https://github.com/Supratim158/face_auth_attendance_system',
liveUrl: '',
imagePath: 'assets/project/face.png',

longDescription:
    'Face Authentication Attendance System is a computer vision-based solution '
    'designed to automate attendance using facial recognition technology. The '
    'system captures live video from a webcam, detects and recognizes registered '
    'faces, and records attendance automatically with timestamps.\n\n'
    'Built using Python and OpenCV, the application minimizes manual effort '
    'while improving reliability and security. It provides a simple interface '
    'for registering users, authenticating identities, and maintaining digital '
    'attendance records, making it suitable for educational institutions and '
    'organizations.',

features: [
  'Real-time face detection and recognition',
  'Automatic attendance marking with timestamps',
  'Secure facial authentication',
  'Student registration and face enrollment',
  'Attendance history management',
  'CSV-based attendance record generation',
  'Fast and accurate computer vision pipeline',
  'Simple desktop interface for administrators',
],

role: 'AI & Computer Vision Developer',
duration: '1 month',
status: 'Completed',
  ),
  // ── PROJECT 8 ─────────────────────────────────────────────
  const Project(
    id: 'filter',
    title: 'Camera Filters Using Python',
tagline: 'Real-time computer vision application with interactive camera filters',

description:
    'A Python-based computer vision application that applies real-time '
    'image processing effects and artistic filters to live webcam feeds '
    'using OpenCV.',

techStack: [
  'PYTHON',
  'OPENCV',
  'NUMPY',
  'TKINTER',
],

githubUrl: 'https://github.com/Supratim158/camera_filters_using_python',
liveUrl: '',
imagePath: 'assets/project/filter.png',

longDescription:
    'Camera Filters Using Python is a real-time image processing application '
    'that demonstrates the capabilities of computer vision using OpenCV. '
    'The application captures live video from a webcam and applies various '
    'visual effects and filters instantly, allowing users to experiment with '
    'different image transformations.\n\n'
    'Developed using Python and OpenCV, the project showcases fundamental '
    'computer vision concepts such as frame processing, color space '
    'transformations, edge detection, blurring, and artistic image effects. '
    'Its lightweight design makes it an excellent demonstration of real-time '
    'image manipulation techniques.',

features: [
  'Real-time webcam video processing',
  'Multiple image filters and visual effects',
  'Grayscale, blur, and edge detection filters',
  'Color transformation and enhancement',
  'Live preview with instant filter switching',
  'High-performance frame processing using OpenCV',
  'Simple and intuitive desktop interface',
  'Lightweight and easy-to-use application',
],

role: 'Computer Vision Developer',
duration: '2 weeks',
status: 'Completed',
  ),
  // ── PROJECT 9 ─────────────────────────────────────────────
  const Project(
    id: 'sudoku',
    title: 'Sudoku Game',
tagline: 'Interactive Sudoku puzzle game with intelligent validation and solving',

description:
    'A desktop Sudoku game developed in Python that provides an engaging '
    'puzzle-solving experience with real-time validation, puzzle generation, '
    'and an intuitive graphical interface.',

techStack: [
  'PYTHON',
  'TKINTER',
  'NUMPY',
  'BACKTRACKING',
],

githubUrl: 'https://github.com/Supratim158/SudokuGame',
liveUrl: '',
imagePath: 'assets/project/sdk.png',

longDescription:
    'Sudoku Game is a desktop application built using Python that recreates '
    'the classic Sudoku puzzle with a clean and user-friendly interface. The '
    'project focuses on implementing the core Sudoku solving logic while '
    'providing an enjoyable gameplay experience.\n\n'
    'The application utilizes the backtracking algorithm to validate and solve '
    'Sudoku puzzles efficiently. It allows users to play interactively, verify '
    'their inputs, and generate valid puzzle solutions, making it an excellent '
    'demonstration of algorithmic problem-solving and GUI development in '
    'Python.',

features: [
  'Interactive 9×9 Sudoku gameplay',
  'Backtracking-based Sudoku solver',
  'Real-time input validation',
  'Puzzle completion checking',
  'Clean and intuitive graphical interface',
  'Efficient Sudoku solving algorithm',
  'Responsive desktop application',
  'Demonstrates recursion and algorithmic problem solving',
],

role: 'Java Developer',
duration: '2 weeks',
status: 'Completed',
  ),
  
];

/// Helper to find a project by its ID.
Project? findProjectById(String id) {
  try {
    return projectList.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
