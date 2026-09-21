import '../models/employee.dart';

final List<Employee> dummyEmployees = [
  Employee(
    id: 'emp-001',
    name: 'I Made Lorem Ipsum Putra',
    position: 'Programer Coordinator',
    branch: 'BLiP - Head Office',
    email: 'loremipsum@gmail.com',
    phone: '+6287865679796',
    organizations: 'Technical & Operation',
    joinDate: '20 April 2020',
    birthDate: '21 Jul',
    photoUrl: 'https://i.pravatar.cc/300?img=68',
  ),
  Employee(
    id: 'emp-002',
    name: 'I Putu Lorem Ipsum Putri',
    position: 'Frontend Developer',
    branch: 'BLiP - Head Office',
    email: 'aswaspsum@gmail.com',
    phone: '+6287865680001',
    organizations: 'Technical & Operation',
    joinDate: '20 Juli 2020',
    birthDate: '22 Jul',
    photoUrl: 'https://i.pravatar.cc/300?img=5',
  ),
  Employee(
    id: 'emp-003',
    name: 'I Wayan Lorem Ipsum Putra',
    position: 'Backend Developer',
    branch: 'BLiP - Head Office',
    email: 'loremipsum@gmail.com',
    phone: '+6287665679706',
    organizations: 'Technical & Operation',
    joinDate: '20 Juni 2020',
    birthDate: '23 Jul',
    photoUrl: 'https://i.pravatar.cc/300?img=59',
  ),
  Employee(
    id: 'emp-004',
    name: 'I Ketut Lorem Ipsum Putra',
    position: 'Front Developer',
    branch: 'BLiP - Branch Office',
    email: 'lupagwidenya@gmail.com',
    phone: '+6287865669721',
    organizations: 'Technical & Operation',
    joinDate: '20 Agustus 2020',
    birthDate: '24 Jul',
    photoUrl: 'https://i.pravatar.cc/300?img=56',
  ),
  Employee(
    id: 'emp-005',
    name: 'I Nyoman Lorem Ipsum Putra',
    position: 'Backend Developer',
    branch: 'BLiP - Head Office',
    email: 'okeakukehabisanide@gmail.com',
    phone: '+6286865079706',
    organizations: 'Technical & Operation',
    joinDate: '20 September 2020',
    birthDate: '25 Jul',
    photoUrl: 'https://i.pravatar.cc/300?img=51',
  ),
];

final List<Employee> dummyAbsentEmployees =[
  Employee(
    id: 'abs-001',
    name: 'Ni Gusti Ipsum Putri',
    branch: 'BLiP - Head Office',
    email: 'dummy@semuaaplikasi.id',
    phone: '+6286865079706',
    position: 'Backend Developer',
    organizations: 'Technical & Operation',
    joinDate: '20 September 2020',
    birthDate: '25 Jul',
    photoUrl: 'https://i.pravatar.cc/300?img=10',
  ),
  Employee(
    id: 'abs-002',
    name: 'I Gusti Lorem Ipsum Putra',
    branch: 'BLiP - Head Office',
    email: 'dummy@semuaaplikasi.id',
    phone: '+6286865079706',
    position: 'Backend Developer',
    organizations: 'Technical & Operation',
    joinDate: '20 September 2020',
    birthDate: '25 Jul',
    photoUrl: 'https://i.pravatar.cc/300?img=7',
  ),
];

class OrgNode {
  final String id;
  final String nik;
  final String name;
  final String position;
  final String department;
  final String photoUrl;
  final bool isUser;
  final bool isEmpty;
  final int childCount;

  OrgNode({
    required this.id,
    this.nik = '',
    this.name = '',
    this.position = '',
    this.department = '',
    this.photoUrl = '',
    this.isUser = false,
    this.isEmpty = false,
    this.childCount = 1,
  });
}

final List<OrgNode> dummyOrgHierarchy = [
  OrgNode(
    id: 'node-0',
    isEmpty: true,
    name: 'Posisi kosong',
    childCount: 1,
  ),
  OrgNode(
    id: 'node-1',
    nik: 'BLIP.02.0818.183',
    name: 'Manuh Artana',
    position: 'Business Integration...',
    department: 'Business Integration',
    photoUrl: 'https://i.pravatar.cc/300?img=11',
    childCount: 1,
  ),
  OrgNode(
    id: 'node-2',
    nik: 'SAI.02.0626.512',
    name: '(Anda) Khusni Ri...',
    position: 'FRONTEND',
    department: 'FRONTEND SAI',
    photoUrl: 'https://i.pravatar.cc/300?img=12',
    isUser: true,
    childCount: 0,
  ),
];