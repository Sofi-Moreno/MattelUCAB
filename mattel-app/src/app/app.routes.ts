import { Routes } from '@angular/router';
import { Designs } from './view/product_designs/designs';
import { Home } from './view/home/home';
import { Login } from './view/login/login';

export const routes: Routes = [
    { path: '', component: Login },
    { path: 'login', component: Login },
    { path: 'home', component: Home },
    { path: 'designs', component: Designs },
];
