import { Routes } from '@angular/router';
import { Designs } from './view/designs/designs';
import { Home } from './view/home/home';
import { Login } from './view/login/login';
import { User } from './view/user/user';
import { Profile } from './view/profile/profile';

export const routes: Routes = [
    { path: '', component: Login },
    { path: 'login', component: Login },
    { path: 'home', component: Home },
    { path: 'user', component: User },
    { path: 'designs', component: Designs },
    { path: 'profile', component: Profile },
];
