import 'task.dart';

// Operational Tasks
List<Task> getDummyOperationalTasks() {
  return [
    // HMI Category
    Task(
      id: 'op1',
      name: 'Waterflow',
      category: 'HMI',
      timeRemaining: '5 hours left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'op2',
      name: 'Physical condition',
      category: 'HMI',
      timeRemaining: '2 hours left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    
    // BLOWER Category
    Task(
      id: 'op3',
      name: 'Motor Vibration',
      category: 'BLOWER',
      timeRemaining: '1 hour left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'op4',
      name: 'Impeller condition',
      category: 'BLOWER',
      timeRemaining: '1 day left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'op5',
      name: 'Top suction mesh condition',
      category: 'BLOWER',
      timeRemaining: '2 hours left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),

    // PNEUMATIC VALVE Category
    Task(
      id: 'op6',
      name: 'Air leakage',
      category: 'PNEUMATIC VALVE',
      timeRemaining: '6 hours left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'op7',
      name: 'Bellow condition',
      category: 'PNEUMATIC VALVE',
      timeRemaining: '30 mins left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
  ];
}

// Completed Operational Tasks
List<Task> getCompletedOperationalTasks() {
  return [
    Task(
      id: 'cop1',
      name: 'Bottom suction mesh condition',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cop2',
      name: 'Belt condition',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cop3',
      name: 'Motor temperature',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cop4',
      name: 'Abnormal noise',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
  ];
}

// Maintenance Tasks
List<Task> getDummyMaintenanceTasks() {
  return [
    // Today's Preventive/Planned Maintenance
    Task(
      id: 'm1',
      name: 'Cold Glass (L/R)',
      category: 'Today\'s Preventive/Planned Maintenance',
      timeRemaining: '3 hours Left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'm2',
      name: 'Burner Cleaning',
      category: 'Today\'s Preventive/Planned Maintenance',
      timeRemaining: '1 hour Left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'm3',
      name: 'Top Roller Cleaning By Brush',
      category: 'Today\'s Preventive/Planned Maintenance',
      timeRemaining: '4 hours Left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'm4',
      name: 'Top Roller Washing',
      category: 'Today\'s Preventive/Planned Maintenance',
      timeRemaining: '30 mins left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    
    // Next Day's Preventive/Planned Maintenance
    Task(
      id: 'm5',
      name: 'Bottom Roller Washing',
      category: 'Next Day\'s Preventive/Planned Maintenance',
      timeRemaining: '1 day left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'm6',
      name: 'Hanging Bricks Cleaning',
      category: 'Next Day\'s Preventive/Planned Maintenance',
      timeRemaining: '1 day left',
      isCompleted: false,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
  ];
}

// Completed Maintenance Tasks
List<Task> getCompletedMaintenanceTasks() {
  return [
    Task(
      id: 'cm1',
      name: 'Zernul Bricks',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cm2',
      name: 'Washing Pump in Running Condition',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cm3',
      name: 'M/c Oil Pump Working',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cm4',
      name: 'Water Inlet Temp.',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cm5',
      name: 'Water Outlet Temp. Top and Bottom Roller',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cm6',
      name: 'Water Outlet Temp. Carraige Roller',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
    Task(
      id: 'cm7',
      name: 'Any Abnormal Sound in Rolling M/c',
      category: 'COMPLETED',
      timeRemaining: '',
      isCompleted: true,
      isRange: false,
      specificationRange: '0.5 to 1.5',
      completedAt: '',
    ),
  ];
}