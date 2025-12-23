# Firestore Database Structure

## Collections

### 1. users/
```
users/{userId}/
├── name: string
├── email: string
├── age: number
├── weight: number
├── height: number
├── gender: string
├── goal: string
└── createdAt: timestamp
```

### 2. users/{userId}/meals/
```
users/{userId}/meals/{mealId}/
├── dishName: string
├── description: string
├── imageUrl: string
├── timestamp: timestamp
├── mealType: string
├── nutritionalInfo: map
│   ├── calories: number
│   ├── protein: number
│   ├── carbs: number
│   └── fat: number
└── ingredients: array
```

### 3. dailyStats/
```
dailyStats/{userId}/dates/{date}/
├── date: timestamp
├── totalCalories: number
├── totalProtein: number
├── totalCarbs: number
├── totalFat: number
├── mealsCount: number
└── lastUpdated: timestamp
```